base:
  'roles:router':
    - match: grain
    - router
  'roles:rancher':
    - match: grain
    - rancher
  'roles:rke':
    - match: grain
    - rke
  '*':
    - ssh-key
