# Configuration overview

The environment provides certain default properties that can be activated for
all projects. Here is an overview of the predefined properties ordered by ID.

| ID | Alias | Name | Description |
|----|-------|------|-------------|
| 80 | localdev | Local Development | General improvements and speed-up for local development. This configuration should always be applied. Parts of the configuration will be overridden by other properties later on to reactivate certain development features. |
| 81 | SSL | SSL Certificates | Activate SSL certificate based on the domain local.cxdev.me. This domain is configured to resolve to localhost and provides a wildcard certificate that can be used for local development. |
| 83 | backoffice | Backoffice development | Activates development mode for backoffice extensions allowing the backoffice configuration to be redeployed without restarting the server (hot deployment). |
| 84 | smartedit | SmartEdit development | Activates development mode for smartedit extensions allowing the smartedit build to update the resources with every build. |
| 88 | SSO | SSO integration | Activates SSO integration with Auth0 with a predefined tenant for CXDEV.me. This tenant works with the local.cxdev.me domain and has all the default users of SAP Commerce included and activated with default passwords set to 1234 |

## Enable a configuration profile globally

To enable a configuration profile you can run one of the following environment
script, providing a profile ID or alias:
```bash
yGlobalConfig enable <ID>
yGlobalConfig enable <ALIAS>
```

For example to activate localdev with SSL and backoffice:
```bash
yGlobalConfig enable localdev
yGlobalConfig enable SSL
yGlobalConfig enable backoffice
```

## Disable a configuration profile globally

To disable a configuration profile you can run one of the following environment
scripts, providing a profile ID or alias:
```bash
yGlobalConfig disable <ID>
yGlobalConfig disable <ALIAS>
```
