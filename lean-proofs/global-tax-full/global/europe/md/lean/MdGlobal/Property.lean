import MdGlobal.Pit
import TaxKernel.Global2

/-!
# MD 2025: taxa de stat on notarised transfers of real estate (4400), impozitul pe bunurile imobiliare (4100)

## 4400 Taxa de stat pentru autentificarea contractelor de înstrăinare a bunurilor imobile
Source: Legea taxei de stat nr. 213 din 31.07.2023, edition in force from 26.09.2024 (the one in force on 01.01.2025),
read on legis.md in a browser on 26 November 2026 (`https://www.legis.md/cautare/getResults?doc_id=145352&lang=ro`).
* art. 4: "Cuantumurile taxei de stat sunt expuse în anexa nr. 1."
* anexa nr. 1 pct. 8.3 "Pentru autentificarea contractelor de înstrăinare a bunurilor imobile, inclusiv aflate în
  proces de construcție": pct. 8.3.1 to children, spouse, parents, siblings, grandparents, grandchildren "0,1% din
  prețul contractului, dar nu mai puțin decât valoarea indicată în Registrul bunurilor imobile", pct. 8.3.2 "altor
  persoane": "0,5% din prețul contractului, dar nu mai puțin decât valoarea indicată în Registrul bunurilor imobile"
* reading taken: "dar nu mai puțin decât valoarea" sets the base (the higher of the price and the registered value)
* reading taken: pct. 8.2 (5 lei for contracts "de vânzare-cumpărare, transmitere-primire a locuinței în proprietate
  privată") is read as the privatisation of public housing, not an ordinary sale between private persons
* the buyer's relation to the seller is not in the input: the rate for other persons (0,5 %) is applied

## 4100 Impozitul pe bunurile imobiliare (framework, local rate input)
Source: Codul fiscal nr. 1163/1997 Titlul VI, edition in force 01.01.2025, read on legis.md (`doc_id=138612`).
* art. 280 (1) a): residential property, garages and garden plots: "cota minimă – 0,05% din baza impozabilă a
  bunurilor imobiliare. Cota concretă se stabileşte anual de către autoritatea reprezentativă şi deliberativă a
  administraţiei publice locale"
* art. 280 (1) b): property other than residential or agricultural: "0,3% din baza impozabilă a bunurilor imobiliare"
* rate as input: `localRates.propertyTax {rate, source, date, municipality}`
* default rate, Chișinău: Dispoziția Primarului General al municipiului Chișinău nr. 588-d din 27.12.2024 "Cu privire
  la aplicarea bugetului municipal Chișinău provizoriu pe anul 2025", pct. 8 and anexa nr. 6 "Cotele impozitului pe
  bunurile imobiliare în municipiul Chișinău pentru anul 2025", pct. 1: residential property, garages and garden plots
  "0,185 % din baza impozabilă a bunurilor imobiliare", pct. 2 farm land with buildings 0,1 %, pct. 3 other property
  0,3 %. Read from the scanned order on chisinau.md (`/ro/upload/278382/attached_files/6776adfbdd58e.pdf`, page 21)
  in a browser on 26 November 2026, chisinau.md's robots.txt disallows scripts.

## From 1 January 2027 (not modelled)
* 4100, Chișinău: Decizia Consiliului Municipal Chișinău nr. 9/2 din 19.11.2026, anexa nr. 2 pct. 1: residential
  property 0,08 % (from 0,185 %, a cut of 0,105 points or 57 %), farm land 0,1 % and other property 0,3 % unchanged
  (`/ro/upload/284400/attached_files/6b00513f1d67e.pdf`)
* 4100, the Code: art. 280 (1) keeps the minimum of 0,05 %, lit. a¹) now covers farm land with or without buildings
* 4400: pct. 8.3.1 and 8.3.2 of anexa nr. 1 to Legea nr. 213/2023 are unchanged (0,1 % and 0,5 %) in the edition in
  force from 01.05.2027 (`doc_id=157014`)
-/

namespace MdGlobal.Property
open TaxKernel TaxKernel.Global

def lfwG (s : String) : CanonGlobal :=
  match Lean.Json.parse s with
  | .ok j => match parseGlobal j with | .ok g => g | .error _ => default
  | .error _ => default

/-- Legea nr. 213/2023 anexa nr. 1 pct. 8.3.2: 0,5 % of the higher of the contract price and the registered value. -/
def duty : TransferDuty :=
  { name := "Taxa de stat (autentificarea contractelor de înstrăinare a bunurilor imobile)",
    sched := Schedule.flat 50, higherOfAssessed := true }

def dutyStatute : String := "Legea taxei de stat nr. 213/2023 anexa nr. 1 pct. 8.3.2 (0,5 %, not less than on the registered value)"

/-- Codul fiscal art. 280 (1) a): at least 0,05 %, the rate set each year by the local council. -/
def propertyTax : LocalTax :=
  { key := "propertyTax", name := "Impozitul pe bunurile imobiliare", base := .assets [.home, .realEstate, .land],
    unit := .percent, minNum := 5, minDen := 100,
    default := some { municipality := "Chișinău", num := 185, den := 1000,
                      source := "Dispoziția Primarului General al municipiului Chișinău nr. 588-d din 27.12.2024, anexa nr. 6 pct. 1 (0,185 %)",
                      date := "2025-01-01" },
    statute := "Codul fiscal art. 280 alin. (1) lit. a) (at least 0,05 % of the taxable base, the local council sets the rate)" }

set_option linter.unusedVariables false in
def families : List Family :=
  [{ name := "4400 Taxa de stat (real-estate transfers)", covers := [.transactions],
     run := fun args g prev => duty.charges g.purchases dutyStatute },
   { name := "4100 Impozitul pe bunurile imobiliare (local rate input)", covers := [.propertyRecurrent],
     run := fun args g prev => propertyTax.charges g }]

def absent : List Absent :=
  []

def notes : List String := ["MD 4400: Legea nr. 213/2023 as in force 01.01.2025, read on legis.md (doc_id=145352)", "MD 4100: Codul fiscal art. 280 as in force 01.01.2025 (doc_id=138612), the local rate is an input, with Chișinău's 0,185 % for 2025 as the default (Dispoziția nr. 588-d din 27.12.2024, anexa nr. 6)"]

set_option linter.unusedVariables false in
def unsupported (args : List String) (g : CanonGlobal) : List String :=
  propertyTax.unknown g
  ++ (if g.purchases.any (fun p => p.kind.isRealEstate) then ["4400: the 0,5 % rate for other persons is applied, a transfer to a child, spouse, parent, sibling, grandparent or grandchild pays 0,1 % (pct. 8.3.1) and the relation is not in the input"] else [])
  ++ (if g.assets.any (fun a => a.kind == .realEstate || a.kind == .land) then ["4100: every asset is taxed as residential property (art. 280 (1) a)), farm land with buildings (lit. a¹), at least 0,1 %) and non-residential property (lit. b), 0,3 %) are not distinguished"] else [])
  ++ (if g.assets.any (fun a => a.kind.isRealEstate) then ["4100: where no rate is given, Chișinău's rate for 2025 (0,185 %) is applied, another municipality's rate goes in localRates.propertyTax, Chișinău's exemption of part of the value for some groups of owners was not read"] else [])

#guard duty.amount { kind := .home, price := 1000000 } == 5000
#guard duty.amount { kind := .home, price := 1000000, assessed := 1200000 } == 6000
#guard duty.amount { kind := .listedShares, price := 1000000 } == 0
#guard ((propertyTax.charges (lfwG "{\"id\":\"h\",\"schema\":\"global/2.0\",\"household\":{\"id\":\"h\",\"adults\":[{\"age\":40}]},\"assets\":[{\"kind\":\"home\",\"value\":1500000,\"assessed\":1000000}],\"localRates\":{\"propertyTax\":{\"rate\":0.1,\"source\":\"worked case (example rate, not a decision)\",\"date\":\"2025-01-01\",\"municipality\":\"(case input)\"}}}")).map (·.due)) == [1000]
#guard ((propertyTax.charges (lfwG "{\"id\":\"h\",\"schema\":\"global/2.0\",\"household\":{\"id\":\"h\",\"adults\":[{\"age\":40}]},\"assets\":[{\"kind\":\"home\",\"value\":1500000,\"assessed\":1000000}]}")).map (·.due)) == [1850]
#guard (propertyTax.charges (lfwG "{\"id\":\"h\",\"schema\":\"global/2.0\",\"household\":{\"id\":\"h\",\"adults\":[{\"age\":40}]},\"assets\":[{\"kind\":\"home\",\"value\":1500000,\"assessed\":1000000}],\"localRates\":{\"propertyTax\":{\"rate\":0.01,\"source\":\"worked case (below the statutory minimum)\",\"date\":\"2025-01-01\",\"municipality\":\"(case input)\"}}}")).isEmpty

end MdGlobal.Property
