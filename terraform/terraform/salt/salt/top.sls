base:
  'roles:router':
    - match: grain
    - router
  'roles:rancher':
    - match: grain
    - rancher
  '*':
    - ssh
