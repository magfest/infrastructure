ip_blacklist:
  - 52.71.155.178   # Kontera running on AWS indexing weird stuff
  - 38.105.201.194   # guy trying to use sqlmap to do sql injections
  - 199.180.114.192  # spamming junk into the prereg form fields
  - 37.147.108.24    # spamming junk into the prereg form fields
  - 46.161.9.3       # spamming junk into the prereg form fields
  - 54.85.182.120    # Amazon bot repeatedly requesting POST only URLs
  # Since we started using fail2ban, we're no longer banning individual SSH bots
  # - 109.236.88.163   # +++++++ SSH bots trying to guess passwords
  # - 116.31.116.20
  # - 116.31.116.21
  # - 116.31.116.27
  # - 116.31.116.33
  # - 121.18.238.19
  # - 121.18.238.20
  # - 121.18.238.22
  # - 121.18.238.29
  # - 121.18.238.32
  # - 121.18.238.9
  # - 122.224.165.228
  # - 148.216.14.87
  # - 180.97.197.10
  # - 180.97.239.9
  # - 182.100.67.113
  # - 182.100.67.173
  # - 182.100.67.174
  # - 210.107.37.81
  # - 218.65.30.152
  # - 218.65.30.170
  # - 218.65.30.41
  # - 218.85.132.233
  # - 218.87.109.246
  # - 218.87.109.248
  # - 218.87.109.249
  # - 221.194.44.194
  # - 221.194.44.216
  # - 221.194.44.218
  # - 221.194.44.219
  # - 221.194.44.223
  # - 221.194.44.227
  # - 222.186.21.145
  # - 222.186.21.35
  # - 222.186.34.143
  # - 222.186.34.185
  # - 222.186.56.102
  # - 222.186.56.119
  # - 40.112.187.184
  # - 91.224.160.10
  # - 91.224.160.106
  # - 91.224.160.184   # +++++++  end of SSH bots trying to guess passwords
