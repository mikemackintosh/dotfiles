CRL=$(openssl s_client -connect $1:443 < /dev/null 2>/dev/null| openssl x509 -text -noout 2>/dev/null | grep crl | sed -e 's/^.*URI:\(.*\)/\1/')
wget -O crl.der $CRL
openssl crl -inform der -in crl.der -noout -nameopt oneline,-esc_msb -text
