# This will desensitise IP address eg. make 10.10.10.10 appear as x.x.10.10
$Log = "2017-01-20T09:43:25+00:00 VM01-059e5b85-06fe-49a7-aff7-f18c1ba20746-0 loadbalancer[30043]: [3a5bdb95-b2bb-4c25-ba67-c5d9547ac235]:  [local0.info] 99.100.1.222:10000 [20/Jan/2017:09:41:46.433] SOMEIP_PROXYVIP_16_HTTPS SOMEIP_PROXYVIP_16_HTTPS/SOMEIP_PROXYVIP_16_HTTPS_10.10.10.10 1/0/99421 233151 -- 51/51/51/26/0 0/0"
$Log
$Log -replace '(([0-9]{1,3}\.){2})',"x.x."
