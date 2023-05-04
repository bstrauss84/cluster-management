https://access.redhat.com/solutions/6010251

**Examples when Subscription Admin needs to be enabled in RHACM-Gitops scenarios**
Red Hat Advanced Cluster Manager (RHACM) 2.3, 2.4, 2.5

**Issue**
There are three scenarios where Subscription-Admin needs to be applied:

1. Have a Subscription which subscribes to an Application which is creating objects in namespaces other than the Subscription itself.

2. We are going to overwrite existing kubernetes-objects which have not been created by the subscription before (for example adding a label to a node object) .

3. Starting with ACM 2.4 Policies residing in git will not be deployed.

**Further explanation.**
1. In usecase one per default all objects are created in the same namespace as the subscription.

2. In usecase two, you would get the following error when checking the status of the subscription :
Obj exists and owned by others, backoff

3. Usecase three is a Security Feature to not simply deploy policies without this additional step. You need to setup Subscription-Admin on the Hub. Use this policy and adjust the user:
(https://github.com/open-cluster-management-io/policy-collection/blob/main/community/CM-Configuration-Management/policy-configure-subscription-admin-hub.yaml).

**Resolution**
In order to implement both usecases you need to apply the Subscription-Admin:
( in case a Subscription was created without being SubscriptionAdmin it needs to be recreated to make the changes effective)
https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.5/html/applications/managing-applications#granting-subscription-admin-privilege

**Create Clusterrole**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: open-cluster-management:subscription-admin
rules:
- apiGroups:
  - app.k8s.io
  resources:
  - applications
  verbs:
  - '*'
- apiGroups:
  - apps.open-cluster-management.io
  resources:
  - '*'
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - namespaces
  verbs:
  - '*'
  ```

**Create ClusterRoleBinding**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: open-cluster-management:subscription-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: open-cluster-management:subscription-admin`
```

Now in a third step you need to add a user to the binding.

In the following we add kube:admin

`oc edit clusterrolebinding open-cluster-management:subscription-admin`

Add the following if it is not already present in the open-cluster-management:subscription-admin cluster role binding:

```yaml
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: kube:admin
````
  
**NOTE:** Use the above method for editing the specific RoleBinding open-cluster-management:subscription-admin for ACM 2.4. There is a known issue with RoleBindings created using the oc adm policy method of assigning a Role to a User as well as using any other named RoleBinding. This will be fixed in the ACM 2.5 release.

**Root Cause**
subscription-admin is disabled per default

**Diagnostic Steps**

`oc get subscription mysubscriptionname -o yaml`

For further troubleshooting check here:
https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.4/html/troubleshooting/troubleshooting
