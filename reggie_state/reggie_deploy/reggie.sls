/root/.ssh/reggie_private_deploy:
  file.managed:
    - mode: 600
    - source: salt://reggie_deploy/ssh_keys/reggie_private_deploy
    - name: /root/.ssh/reggie_private_deploy

/root/.ssh/reggie_private_deploy.pub:
  file.managed:
    - mode: 600
    - source: salt://reggie_deploy/ssh_keys/reggie_private_deploy.pub
    - name: /root/.ssh/reggie_private_deploy.pub
