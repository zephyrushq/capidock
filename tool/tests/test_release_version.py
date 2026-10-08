import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from tool.release_version import bump, plan_release, version_code


class VersionTests(unittest.TestCase):
    def test_every_non_feature_change_produces_a_patch(self):
        for message in ("fix: reconnect", "docs: help", "ci: build", "chore: tidy", "Merge branch"):
            with self.subTest(message=message):
                self.assertEqual(bump((0, 2, 1), [message]), (0, 2, 2))

    def test_highest_change_wins_across_the_entire_push(self):
        self.assertEqual(bump((0, 2, 1), ["fix: error", "feat(ssh): connect"]), (0, 3, 0))
        self.assertEqual(bump((0, 2, 1), ["feat: connect", "refactor(api)!: new format"]), (1, 0, 0))
        for footer in ("BREAKING CHANGE: new format", "BREAKING-CHANGE: new format"):
            self.assertEqual(bump((1, 2, 3), [f"fix: parser\n\n{footer}"]), (2, 0, 0))

    def test_android_codes_increase_and_reject_overflow(self):
        versions = [(0, 2, 1), (0, 2, 2), (0, 3, 0), (1, 0, 0)]
        self.assertEqual([version_code(v) for v in versions], [2001, 2002, 3000, 1000000])
        for version in ((0, 0, 0), (0, 1, 1000), (0, 1000, 0), (2101, 0, 0)):
            with self.assertRaises(ValueError):
                version_code(version)


class GitHistoryTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.previous_cwd = Path.cwd()
        os.chdir(self.directory.name)
        self.addCleanup(os.chdir, self.previous_cwd)
        environment = patch.dict(os.environ, {"GIT_CONFIG_GLOBAL": os.devnull, "GIT_CONFIG_NOSYSTEM": "1"})
        environment.start()
        self.addCleanup(environment.stop)
        self.git("init", "-q", "--initial-branch=release")
        self.git("config", "user.name", "Release test")
        self.git("config", "user.email", "test@example.invalid")
        Path("pubspec.yaml").write_text("name: capidock\nversion: 0.2.1+3\n")
        self.git("add", "pubspec.yaml")
        self.commit("feat: initial app")

    def git(self, *args):
        return subprocess.check_output(["git", *args], text=True).strip()

    def commit(self, message):
        self.git("commit", "-q", "--allow-empty", "-m", message)

    def test_bootstrap_and_rerun_keep_the_same_release(self):
        initial = plan_release()
        self.assertEqual(initial["version"], "0.2.1")
        self.assertEqual(initial["build_number"], 2001)
        self.git("tag", initial["tag"])
        repeated = plan_release()
        self.assertTrue(repeated["tag_exists"])
        self.assertEqual(repeated["sha"], initial["sha"])
        self.assertEqual(repeated["version"], initial["version"])
        self.assertEqual(repeated["commits"], initial["commits"])

    def test_uses_commits_since_last_release_and_ignores_other_tags(self):
        self.git("tag", "v0.2.1")
        self.git("tag", "v99.0.0-preview")
        self.commit("fix: storage")
        self.commit("feat(workspaces): rename")
        result = plan_release()
        self.assertEqual(result["version"], "0.3.0")
        self.assertEqual(len(result["commits"]), 2)
        self.assertFalse(result["tag_exists"])
        self.git("tag", result["tag"])
        repeated = plan_release()
        self.assertEqual(repeated["commits"], result["commits"])
        self.assertEqual(repeated["build_number"], result["build_number"])

    def test_explicit_version_floor_reconciles_local_play_builds(self):
        self.git("tag", "v0.2.1")
        Path("pubspec.yaml").write_text("name: capidock\nversion: 0.7.0+7000\n")
        self.git("add", "pubspec.yaml")
        self.commit("feat: prepare server management release")
        result = plan_release()
        self.assertEqual(result["version"], "0.7.0")
        self.assertEqual(result["build_number"], 7000)
        self.git("tag", result["tag"])
        self.assertEqual(plan_release()["version"], "0.7.0")
        self.commit("fix: follow-up")
        self.assertEqual(plan_release()["version"], "0.7.1")

    def test_cannot_release_old_or_rewritten_history(self):
        original = self.git("rev-parse", "HEAD")
        self.commit("feat: future")
        self.git("tag", "v0.3.0")
        self.git("checkout", "-q", original)
        with self.assertRaisesRegex(ValueError, "ancestor"):
            plan_release()


if __name__ == "__main__":
    unittest.main()
