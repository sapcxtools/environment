# SAP JCO Connector for local development

If you are using SAP JCO extensions to call RFC on SAP ERP directly, you will
need to download the SAP JCO Connector for your system architecture manually
from the [SAP Support page for SAP JCO Connector](https://support.sap.com/en/product/connectors/jco.html).

Please download the right ZIP archive, extract it to the dependency directory
and create a symlink called `current` to it.

For example, if you have downloaded the 64-bit ARM version for Apple macOS and
extracted it to `/Users/${USER}/.cxdev/dependencies/sapjco/sapjco3-darwinarm64-3.1.11/`
then you should create a link by using:

```bash
cd /Users/${USER}/.cxdev/dependencies/sapjco/
ln -s sapjco3-darwinarm64-3.1.11/ current
```

After providing this link, the CX DEV environment will take care of patching
your local server installation while running a project configuration process.
