

aud_to_cad = 1.0079
cad_to_usd = 1.0090
usd_to_cad = 0.9911

aud_to_usd = aud_to_cad * cad_to_usd

# p aud_to_usd

yonkers = 19.68 * aud_to_usd
nashua = 58.58 * aud_to_usd
camden = 54.64

total = camden + nashua.round(2) + yonkers.round(2)

p total