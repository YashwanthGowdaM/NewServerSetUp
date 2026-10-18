# Jenkins Installation

This script installs and configures Jenkins on Ubuntu.

## Download the Script

```bash
curl -O https://raw.githubusercontent.com/YashwanthGowdaM/NewServerSetUp/main/Jenkins/setupJenkins.sh
```

## Make the Script Executable

```bash
chmod +x setupJenkins.sh && sudo ./setupJenkins.sh
```

## Script Output

After successful execution, the script displays:

```text
==========================================
 Jenkins Installation Completed
==========================================
Jenkins Status : active
URL            : http://<PUBLIC_IP>:8080
Initial Password:
<password>
==========================================
```

Open the URL in your browser and complete the Jenkins setup.
