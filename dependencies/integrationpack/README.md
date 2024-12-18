# SAP Commerce Integration Pack artefacts

This directory will be used to cache all local available SAP Commerce
Integration Pack versions. This will save a lot of local disk space by sharing
these artefacts for all your local projects.

## Downlaod a new SAP Commerce Integration Pack artefact

Unfortunately, SAP does not provide an artefact server for downloading the
integration packs automatically. Therefore, users must download them manually
from SAP.me.

Please login to your me.sap.com account and visit the download section for the
[SAP Commerce Integration Pack 2211.x][SAPCXINTPACK] and download the required
versions for your project into your local dependency folder at `/Users/${USER}/.cxdev/dependencies/integrationpack/`.
The files typically have random looking IDs in their name. In order to be
processable by the environment, the environment will automatically create
symbolic links using a more stable versioning pattern `CXCOMIEP-<major>.<minor>.ZIP`.

Please keep those links untouched, the environment will take care of them.

## Delete an old SAP Commerce Integration Pack artefact
If you want to remove a version from you local dependency folder, because you
no longer need it, simply remove the original downloaded file from your folder
at `/Users/${USER}/.cxdev/dependencies/integrationpack/`

[SAPCXINTPACK]: https://me.sap.com/softwarecenterviewer/73554900100900007161/INST "SAP Commerce Integration Pack 2211.x"
