# MD kernel 2.0: PROGRESS

Created by new_country.py from cmp20/world/B05-former-ussr/md/lean. Families: none yet.

## 2026-11-26: families from the official texts (contributed)

The seven family files were rewritten by hand from the official texts, read on legis.md in a browser (legis.md answers
403 to scripts). Each file's header names the acts, their editions (`doc_id`) and the provisions it uses.

* now modelled: gains of individuals (1100), VAT classes from art. 96 and 103 (5111), excise on beer, vermouth,
  spirits, cigarettes, other tobacco, petrol, diesel and heating oil (5121), corporate tax with the 7 % farm rate, the
  4 % regime and the IT-park single tax, and withholding (1200), road tax on cars, motorcycles, lorries, buses and
  tractors (5200), stamp duty on real-estate transfers (4400), property tax with the local rate as input and
  Chișinău's 2025 rate as the default (4100), employer social contributions (2200), the employee's health premium
  (2100), the fixed contributions of the self-employed (2300), the wealth tax (4200)
* inheritance and gift tax recorded as not levied (4300)
* still grade C: other taxes (6000)
* grades: A 12 (one of them not levied, one framework), B 2 (excise, self-employed), C 1. 67 `#guard`s, 11 cases
* each family file ends its header with what changes on 1 January 2027 and by how much (not modelled: the model is 2025)
* not regenerated: `../tools/specs/MD_*.py` still describe the earlier pass, and `results/check.json` is the harness
  output of 2026-11-21. `MdTax/` (the income-tax model) is untouched, so `VENDORED.sha256` holds.
