# use system calls to clone Open Charge Map for Czechia

system("./data-raw/ocm-checkout.sh")
system("git sparse-checkout disable")
