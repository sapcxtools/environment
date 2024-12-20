# SAP artefacts

This directory will be used to cache all local available SAP artefact versions.
This will save a lot of local disk space by sharing these artefacts for all
your local projects.

## Downlaod a new SAP Commerce Suite artefact

Unfortunately, SAP does not provide an artefact server for downloading the
integration packs automatically. Therefore, users must download them manually
from SAP.me.

Please login to your me.sap.com account and visit the download section for the
[SAP Commerce Suite 2211.x][SAPCXCOMMERCE] and download the required versions
for your project into your local dependency folder at
`$CXDEVHOME/dependencies/sapartifacts/`. You may want to use a subdirectory
named as the artefact with subfolders of the years. Use those as you like,
eg. `$CXDEVHOME/dependencies/sapartifacts/hybris-commerce-suite/2211/`.

The artefact files provided by SAP typically have random looking IDs in their
name, but the environment is able to parse the IDs and map them into a stable
versioning pattern `<artefactname>-<major>.<minor>.zip`. Please keep those
files untouched, the environment will take care of them.

## Downlaod a new SAP Commerce Integration Pack artefact

Unfortunately, SAP does not provide an artefact server for downloading the
integration packs automatically. Therefore, users must download them manually
from SAP.me.

Please login to your me.sap.com account and visit the download section for the
[SAP Commerce Integration Pack 2211.x][SAPCXINTPACK] and download the required
versions for your project into your local dependency folder at
`$CXDEVHOME/dependencies/sapartifacts/`. You may want to use a subdirectory
named as the artefact with subfolders of the years. Use those as you like,
eg. `$CXDEVHOME/dependencies/sapartifacts/hybris-commerce-integrations/2211/`.

The artefact files provided by SAP typically have random looking IDs in their
name, but the environment is able to parse the IDs and map them into a stable
versioning pattern `<artefactname>-<major>.<minor>.zip`. Please keep those
files untouched, the environment will take care of them.

## Delete an old SAP artefact
If you want to remove a version from you local dependency folder, because you
no longer need it, simply remove the original downloaded file from your folder
at `$CXDEVHOME/dependencies/`

[SAPCXCOMMERCE]: https://me.sap.com/softwarecenterviewer/73554900100900007112/INST "SAP Commerce Suite 2211.x"
[SAPCXINTPACK]: https://me.sap.com/softwarecenterviewer/73554900100900007161/INST "SAP Commerce Integration Pack 2211.x"
