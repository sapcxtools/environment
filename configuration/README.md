# Configuration overview

The environment provides certain default properties that can be activated for
all projects. Here is an overview of the predefined properties ordered by ID.

| ID | Alias | Name | Description |
|----|-------|------|-------------|
| 90 | localdev | Local Development | General improvements and speed-up for local development. This configuration should always be applied. Parts of the configuration will be overridden by other properties later on to reactivate certain development features. |
| 91 | SSL | SSL Certificates | Activate SSL certificate based on the domain local.cxdev.me. This domain is configured to resolve to localhost and provides a wildcard certificate that can be used for local development. |
| 93 | backoffice | Backoffice development | Activates development mode for backoffice extensions allowing the backoffice configuration to be redeployed without restarting the server (hot deployment). |
| 94 | smartedit | SmartEdit development | Activates development mode for smartedit extensions allowing the smartedit build to update the resources with every build. |
| 98 | SSO | SSO integration | Activates SSO integration with Auth0 with a predefined tenant for CXDEV.me. This tenant works with the local.cxdev.me domain and has all the default users of SAP Commerce included and activated with default passwords set to 1234 |

## Enable a configuration profile globally

To enable a configuration profile you can run one of the following environment
script, providing a profile ID or alias:
```bash
yLocalConfig enable <ID>
yLocalConfig enable <ALIAS>
```

For example to activate localdev with SSL and backoffice:
```bash
yLocalConfig enable localdev
yLocalConfig enable SSL
yLocalConfig enable backoffice
```

## Disable a configuration profile globally

To disable a configuration profile you can run one of the following environment
scripts, providing a profile ID or alias:
```bash
yLocalConfig disable <ID>
yLocalConfig disable <ALIAS>
```
