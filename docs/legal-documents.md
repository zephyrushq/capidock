# In-app legal documents

Terms of Use and Privacy Policy are bundled offline in `assets/legal/` for
en-GB, en-US, pt-PT, pt-BR and es-ES. They identify
ZEPHYRUS PROSPERITY - UNIPESSOAL LDA and `legal@zephyrushq.com`.
The same JSON content is used for the in-app reader and static HTML export.

Documents are available from the locked screen, onboarding footer, App settings and About
Capidock dialog. Reading them never loads the credential vault or requires a
network connection. They do not add a consent checkbox, a consent database,
telemetry, a backend or restrictions to the GPL licence.

## Publish the public policy

```sh
python3 tool/export_legal.py
```

Publish the generated `build/legal-site/` directory to a stable public HTTPS
location on the company website. Use the direct `privacy-en-GB.html` page URL
in Play Console and offer the other languages at the same location. The exported
pages contain no analytics, external scripts, fonts or stylesheets.

No hosting configuration, website deployment or Play Console field is changed
by the export. Do not enter a proposed URL until that page is actually published
and accessible without authentication or geographic restrictions.

## Maintenance

Review the text before publication, especially company correspondence practices,
legal obligations and consumer rights. This implementation is a descriptive draft,
not independent legal review or a claim that compliance is complete. Contact the
company's legal adviser to finalise legal wording where necessary.

When data handling changes, update all five JSON files, their date/revision and
store disclosures together; regenerate the public HTML and rebuild the app.
Deleting a workspace does not remove every stored SSH trust record. App settings
can forget individual records or erase all saved server data after device
authentication; this preserves language and terminal preferences. Clearing Android
app storage removes preferences too. Local erasure never revokes remote credentials.
These limits are disclosed.
The app does not record contractual acceptance or treat reading a privacy notice
as consent for unrelated data processing.

Sources:

- [Google Play User Data requirements](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en-GB)
- [European Commission: data protection information for individuals](https://commission.europa.eu/law/law-topic/data-protection/information-individuals_en)
