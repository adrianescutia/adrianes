# OpenShift Cheatsheet Commands

## Collaborating with Other Users

```s
oc login --username user1 --password user1
# create project
oc new-project mysecrets
# add the ability for user developer to view project
oc adm policy add-role-to-user view developer -n mysecrets
# Add user to a project, granted to create new deployments or deleting applications
oc adm policy add-role-to-user edit <username> -n <project>
# Add user to a project, joint owner of the project with administration rights, including the ability to delete the project
oc adm policy add-role-to-user admin <username> -n <project>

oc whoami --show-server
```

## Switching Between Accounts

State about the current login session is stored in the home directory of the local user running the `oc` command, then can only interact with one OpenShift cluster at a time. It is NOT possible to open a separate shell on the same computer.

If you are working against multiple OpenShift clusters, to switch between them, you again use `oc login`, but supply just the URL for the OpenShift cluster. If you do not explicitly specify which user to use, it will use whatever was the last user you were logged in as with that cluster.

```s
oc login https://30.103.6.65:8443 --username user1 --password user1
# see what the current context is by running:
oc whoami --show-context
# get a list of all OpenShift clusters you have ever logged into
oc config get-clusters
# get a list of all contexts which have ever been created, indicating what users on those clusters you have logged in as, and which projects you have worked on
oc config get-contexts
```

## How to deploy an application on OpenShift with the web console and with the oc command line tool

### Deploying existing container images on an OpenShift cluster

**deployment name**, is a unique name given to the component that will be used to name associated resources. This will include the internal Service name used by other applications in the same project to communicate with it, as well as being used as part of the default hostname for the application when exposed externally to the cluster via a _Route_.

_Application Name_ used to group multiple deployments together under the same name as part of one overall application. IS a unique name given to the application grouping to label resources.

_Create a route to the application_ Exposes application at a public URL. Disable it if the deployment won't be accessible outside of the cluster, or it was not a web service.

**TL;DR**

Deploy an application from a container image found on an external image registry. If there is any ambiguity as to the source of the image, use the --docker-image option

```s
oc new-app <docker-image> --name <name>
```

```s
# confirm that the image is found on the Docker Hub Registry
oc new-app --search openshiftkatacoda/blog-django-py
# deploy the image - OpenShift will assign a default name based on the name of the image
oc new-app openshiftkatacoda/blog-django-py
# To specify a different name to be given to the application supplying the --name
oc new-app openshiftkatacoda/blog-django-py --name my-blog
# Application is not exposed. To expose services to the outside world (if required)
oc expose svc/blog-django-py
# to view the hostname assigned to the route created
oc get route/blog-django-py
oc status
# to see more details
oc status --suggest
# list of all the resources that have been created in a project
oc get all -o name
# display the details on one resource to determine what labels may have been added
oc describe route/blog-django-py
```

### OpenShift Web Console’s Topology view

```s
```

### OpenShift Projects and Applications

```s
```

### OpenShift oc tool’s new-app subcommand

```s
```

### Delete OpenShit Application

When only one application exists, all the resources listed will relate to a project. When multiple applications deployed, identify those which are specific to the application to delete. That is possible by applying a command to a subset of resources using a label selector.

```s
# list of all the resources that have been created in a project
oc get all -o name
# display the details on one resource to determine what labels may have been added
oc describe route/blog-django-py
# when deploying an existing container image via the OpenShift web console, OpenShift applies automatically to all resources the label app=<application-name>
oc get all --selector app=blog-django-py -o name
# Having a way of selecting just the resources for the one application, schedule them for deletion
oc delete all --selector app=blog-django-py
# confirm that the resources have been deleted
oc get all --selector app=blog-django-py -o name
```

Although label selectors can be used to qualify what resources are to be queried, or deleted, do be aware that it may not always be the `app` label that need to be used. When an application is created from a template, the labels applied and their names are dictated by the template. As a result, a template may use a different labelling convention. Always use `oc describe` to verify what labels have been applied and use `oc get all --selector` to verify what resources are matched before deleting any resources.
