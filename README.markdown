## Envy Labs Key Master

http://keymaster.envylabs.com

The key master, in cooperation with the gate keeper, manages all public key and user access to project servers.

Users may be added to the system (thereby storing their public SSH key) and then assigned to zero or more projects in the system.  The physical project servers then run the gate keeper - via cron - and continuously update their local users and key pairs for their project.

The actual data transferred is very small, being only YAML-ized Ruby hashes.

### Sample cron task

The following is a sample cron task, assuming that the gate keeper file is stored as "gatekeeper.rb" in root's home directory.

```bash
*/5 * * * * PROJECT="envylabs" /root/gatekeeper.rb &> /dev/null
```

This will automatically sync the system users and their SSH key pairs with the key master every 5 minutes of every hour of every day.

### Sample Workflow

The following is a sample workflow of adding a Project, and assigning users:

```ruby
project = Project.create!(:name => 'New Project')
  #<Project id: 1, name: "New Project", created_at: "2010-04-15 23:28:22", updated_at: "2010-04-15 23:28:22">

user = User.first
  #<User id: 1, login: "testlogin", full_name: "Test User", public_ssh_key: "ssh-dss AAAAB3NzaC1kc3MAAAEBANA6UB7GRWHe3NrJ99aQKst...", uid: 5000, created_at: "2010-02-22 05:19:33", updated_at: "2010-02-22 06:24:06">
user2 = User.create!(:login => 'newlogin', :full_name => 'New User', :public_ssh_key => File.read("id_dsa.pub"), :uid => 5001)
  #<User id: 2 ...>

project.users << user
project.users << user2
```

Then, for the gatekeeper.rb client, you execute it with:

```bash
$ PROJECT="new-project" ./gatekeeper.rb
```

This will contact the central server, inquiring for the authorized users for the given project.  Those users will then be synchronized to have sudo access with their stored public SSH keys, as well as add their SSH keys to the deploy user on the system (who does not have sudo access).

### Environment Variables

This application expects certain environment variables to be set:

* PUBLIC_SIGNING_KEY -- Your public key to verify the signature on the client side (gatekeeper.rb)
* PRIVATE_SIGNING_KEY -- Your private key for signing the server responses.
