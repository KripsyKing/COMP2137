---
# target1.yaml - installs a web server on target1 and locks down the firewall

- name: Configure target1 as a web server
  hosts: target1-mgmt        # the machine this play runs on
  remote_user: remoteadmin   # log in as remoteadmin
  become: yes                # run the tasks with sudo
  tasks:
    # install the apache2 web server package
    - name: Install apache2
      apt:
        name: apache2
        state: present
        update_cache: yes

    # allowing ssh 
    - name: Allow ssh through firewall
      community.general.ufw:
        rule: allow
        port: '22'
        proto: tcp

    # allowing web traffic to apache
    - name: Allow http through firewall
      community.general.ufw:
        rule: allow
        port: '80'
        proto: tcp

    # turn the firewall on last, after the rules exist
    - name: Enable ufw
      community.general.ufw:
        state: enabled
