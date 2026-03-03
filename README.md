# Three Tier App Deployed on AKS

![System Flow](assets/image.png)

### Error Postmortems and RCA:

1. _ImagePullBackOff Errors:_
   - Turns out the AcrPull role was assigned to the controlPlane identity instead of kubeletIdentity. Reattaching the ACR to AKS fixes the issue
2. _CrashLoopBackOff Errors:_
   - Backend container is running but logs show it is unable to connect to Azure PostgresDB. Upon checking the DNS resolution with a test pod and nslookup it did find the DNS entry with the IP
   - Backend pod logs showed error when trying to create an extension uuid-ossp from code. The extension needs to be in the azure.extension's allow-list which was causing the crash.
