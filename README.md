# k8s repo

This repo is for storing the deployment manifests for Kubernetes repo for cloud build.  

# In relation to this the CI/CD Pipeline is described as follows:-

When a change is pushed to the blaise_survey_manager repository the following happens:-

    Build of repo using SHORT_SHA
    Three SSH steps are carried out:
        * GCloud decrypts file containing the SSH key and stores it in a volume named ssh
        * Set up git with key and domain adding it to the known_hosts file
        * Connects to the k8s repository - using key in ssh volume
    
The coresponsding container image is built (for blaise_survey_manager repo) and this is pushed to Container Registry.

Once the image is pushed, the Kubernetes deployment manifest (bsm.yaml) is updated to use that new image and this is pushed to the candidate branch of the k8s repository. 

This triggers the actual deployment in Kubernetes of the k8s repository. A Deployment occurs (using bsm.yaml) and the three SSH steps are carried out (as described above)

Once the deployment is finished, the new manifest is copied over to the dev branch of the k8s repository.

In the end, you have a system where:

* The candidate branch is a history of the deployment attempts.
* The dev branch is a history of the successful deployments.
* You have a view of successful and failed deployments in Cloud Build.
* You can rollback to any previous deployment by re-executing the corresponding job in Cloud Build. A rollback also updates the production branch to truthfully reflect the history of deployments.


