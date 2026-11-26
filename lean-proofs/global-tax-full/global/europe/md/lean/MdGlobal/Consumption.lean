import MdGlobal.Pit
import TaxKernel.Global2

/-!
# MD 2025: Taxa pe valoarea adăugată (5111) and accizele (5121)

Source: Codul fiscal nr. 1163/1997, Titlul III and Titlul IV, edition in force 01.01.2025, read on legis.md in a
browser on 25 and 26 November 2026 (`https://www.legis.md/cautare/getResults?doc_id=138612&lang=ro`).

## 5111 T.V.A.
* art. 96 lit. a): "cota-standard – în mărime de 20% din valoarea impozabilă a mărfurilor şi serviciilor importate şi
  a livrărilor efectuate pe teritoriul Republicii Moldova"
* art. 96 lit. b), reduced rates of 8 %: bread and bakery products, milk and dairy products, registered medicines,
  natural and liquefied gas (position 2711) and its transport and distribution, unprocessed farm and horticultural
  produce of the listed positions, beet sugar, solid biofuel, "serviciile de cazare, indiferent de categoria de
  confort", "produsele alimentare şi/sau băuturi, cu excepţia producţiei alcoolice, preparate sau nepreparate, pentru
  consumul uman, însoţite de servicii conexe care să permită consumul imediat al acestora"
* art. 103 (1), exempt without the right to deduct: pct. 1) "locuinţa, pămîntul, locaţiunea locuinţei", pct. 5)
  education, pct. 10) "serviciile medicale, cu excepţia celor cosmetice", pct. 12) financial services, lit. g)
  insurance and reinsurance, pct. 17) passenger transport within the country, pct. 20) books and periodicals
* art. 112 (1): registration is compulsory when supplies in 12 consecutive months exceed "1,2 milioane de lei"

## 5121 Accize (Titlul IV, anexa nr. 1 "Mărfurile supuse accizelor", column "Anul 2025")
* 220300 beer made from malt: "3,05 lei" per litre
* 2207, 2208 ethyl alcohol, spirits, liqueurs: "132,27 lei" per litre of absolute alcohol
* 240220 cigarettes, with and without filter: "1081,43 lei +13%, dar nu mai puţin de 1450,48 lei" per 1000 pieces,
  art. 123¹ (1), (2): the ad valorem part is "calculate la preţul maxim de vînzare cu amănuntul"
* 271012110–271019290 light and medium oils (petrol): "8837,49 lei" per tonne
* 271019310–271019480 gas oil, diesel fuel included: "3718,64 lei" per tonne
* wine of fresh grapes (position 2204) is not in the annex, 2205 vermouth and other flavoured wines: "17,37 lei" a litre
  (a wine line with `"sub": "vermouth"`)
* 271019310–271019480 covers heating fuel as well ("combustibil pentru cuptoare"): heating oil at the diesel rate
* 2403 smoking tobacco and other manufactured tobacco: "210,54 lei" per kilogram (the line's `"massG"`)
* petrol and diesel are taxed per tonne and the basket gives litres: the mass is the line's `"massG"`, else a density
  the model assumes (0,75 kg per litre of petrol, 0,84 kg per litre of diesel), which is not in the Code

## From 1 January 2027 (not modelled)
Codul fiscal as in force 01.01.2027 (`doc_id=152862`, carrying Legea nr. 247/2026), read the same way, the model is for 2025 and does not apply these.
* art. 96 is rewritten. The standard rate stays 20 %. A new reduced rate of 12 % (alin. (2) pct. 1)) takes
  accommodation and food served for immediate consumption, which paid 8 % (+4 points), with unprocessed farm produce of
  the listed positions and some dairy products. The 8 % rate (pct. 2)) keeps bread, milk, medicines and medical
  devices, natural and liquefied gas, solid biofuel, and listed fresh vegetables, fruit and cereals.
* excise, anexa nr. 1 tabelul nr. 1 as replaced by Legea nr. 247/2026 (the annex file linked from the 2027 edition),
  column "Anul 2027" against 2025:
  beer 3,4 lei a litre (3,05, +11 %), spirits 145,5 lei per litre of absolute alcohol (132,27, +10 %),
  cigarettes "1428 lei +13%, dar nu mai puțin de 1915 lei" per 1000 (1081,43 and 1450,48, +32 %),
  petrol 10401,7 lei a tonne (8837,49, +18 %), diesel 4774,7 lei a tonne (3718,64, +28 %),
  vermouth 19,1 lei a litre (17,37, +10 %)
-/

namespace MdGlobal.Consumption
open TaxKernel TaxKernel.Global

def vat : Vat :=
  { name := "Taxa pe valoarea adăugată", standard := 2000, reduced := 800, threshold := 1200000,
    classOf := fun gd => match gd with
      | .health | .education | .financial | .insurance | .rent | .books | .newspapers => .exempt
      | .medicines | .gas | .hotels | .restaurants => .reduced
      | _ => .standard }

def vatStatute : String := "Codul fiscal art. 96 lit. a) (20 %), lit. b) (8 %), art. 103 alin. (1) (exempt), art. 112 alin. (1) (1,2 million lei)"

def exciseName : String := "Accize"

def beer : ExciseRule :=
  { good := .beer, name := exciseName, perUnitNum := 305, perUnitDen := 100,
    statute := "Codul fiscal Titlul IV anexa nr. 1, poziția 220300 (2025: 3,05 lei per litre)" }

def spirits : ExciseRule :=
  { good := .spirits, name := exciseName, perUnitNum := 13227, perUnitDen := 100, onPureAlcohol := true,
    statute := "Codul fiscal Titlul IV anexa nr. 1, pozițiile 2207, 2208 (2025: 132,27 lei per litre of absolute alcohol)" }

def cigarettes : ExciseRule :=
  { good := .cigarettes, name := exciseName, perUnitNum := 108143, perUnitDen := 100000, adValoremBp := 1300,
    minNum := 145048, minDen := 100000,
    statute := "Codul fiscal Titlul IV anexa nr. 1, poziția 240220 (2025: 1081,43 lei + 13 % per 1000, at least 1450,48 lei), art. 123¹" }

def petrol : ExciseRule :=
  { good := .petrol, name := exciseName, perKgNum := 883749, perKgDen := 100000, mgPerUnit := 750000,
    statute := "Codul fiscal Titlul IV anexa nr. 1, pozițiile 271012110–271019290 (2025: 8837,49 lei per tonne)" }

def diesel : ExciseRule :=
  { good := .diesel, name := exciseName, perKgNum := 371864, perKgDen := 100000, mgPerUnit := 840000,
    statute := "Codul fiscal Titlul IV anexa nr. 1, pozițiile 271019310–271019480 (2025: 3718,64 lei per tonne)" }

/-- Wine of fresh grapes (position 2204) is not among the goods of anexa nr. 1: a cited zero. -/
def wine : ExciseRule :=
  { good := .wine, name := exciseName,
    statute := "Codul fiscal Titlul IV anexa nr. 1: position 2204 (wine of fresh grapes) is not listed" }

/-- 2205: vermouth and other flavoured wines, a wine line with `"sub": "vermouth"`. Listed before `wine`. -/
def vermouth : ExciseRule :=
  { good := .wine, sub := "vermouth", name := exciseName, perUnitNum := 1737, perUnitDen := 100,
    statute := "Codul fiscal Titlul IV anexa nr. 1, poziția 2205 (2025: 17,37 lei per litre)" }

def heatingOil : ExciseRule :=
  { good := .heatingOil, name := exciseName, perKgNum := 371864, perKgDen := 100000, mgPerUnit := 840000,
    statute := "Codul fiscal Titlul IV anexa nr. 1, pozițiile 271019310–271019480 (2025: 3718,64 lei per tonne)" }

def tobaccoOther : ExciseRule :=
  { good := .tobaccoOther, name := exciseName, perKgNum := 21054, perKgDen := 100,
    statute := "Codul fiscal Titlul IV anexa nr. 1, poziția 2403 (2025: 210,54 lei per kilogram)" }

def exciseRules : List ExciseRule := [beer, vermouth, wine, spirits, cigarettes, petrol, diesel, heatingOil, tobaccoOther]

/-- The first rule that fits each line. Other tobacco is taxed by mass: a line without `massG` would compute 0, so
its charge is dropped and the line is listed in `unsupported` instead. -/
def exciseCharges (g : CanonGlobal) : List Charge :=
  (exciseRuleCharges exciseRules g (firstOnly := true)).filter fun c =>
    !(c.event == Good.tobaccoOther.name && c.due == 0)

set_option linter.unusedVariables false in
def families : List Family :=
  [{ name := "5111 Taxa pe valoarea adăugată", covers := [.vat],
     run := fun args g prev =>
       (if g.consumption.isEmpty then [] else [vat.basketCharge g.consumption vatStatute])
       ++ (if g.entity == .company && !g.company.sales.isEmpty then [vat.businessCharge g.company vatStatute] else []) },
   { name := s!"5121 {exciseName}", covers := [.excise], run := fun args g prev => exciseCharges g }]

def absent : List Absent :=
  []

def notes : List String := ["MD 5111, 5121: Codul fiscal as in force 01.01.2025, read on legis.md (doc_id=138612)"]

set_option linter.unusedVariables false in
def unsupported (args : List String) (g : CanonGlobal) : List String :=
  (if g.consumption.any (fun s => s.good == .food) then ["5111: food at the standard rate, bread, dairy products, unprocessed farm produce and beet sugar pay 8 % (art. 96 lit. b)) and are not separable in the basket's food line"] else [])
  ++ (if g.consumption.any (fun s => s.good == .transport) then ["5111: transport at the standard rate, passenger transport within the country is exempt (art. 103 (1) pct. 17)) and is not separable in the basket's transport line"] else [])
  ++ (if g.consumption.any (fun s => s.good == .restaurants) then ["5111: restaurants at 8 %, alcoholic drinks served there pay 20 % (art. 96 lit. b)) and are not separable"] else [])
  ++ (if g.consumption.any (fun s => s.good == .petrol || s.good == .diesel) then ["5121: fuel is taxed per tonne, where the line gives no massG, the model assumes 0,75 kg per litre of petrol and 0,84 kg per litre of diesel (not in the Code)"] else [])
  ++ (if g.consumption.any (fun s => s.good == .wine) then ["5121: wine at no excise (position 2204 is not in anexa nr. 1). Vermouth and other flavoured or fermented drinks (2205, 2206: 17,37 lei a litre) are taxed when the line says sub vermouth"] else [])
  ++ (if g.consumption.any (fun s => s.good == .tobaccoOther) then ["5121: other tobacco is taxed per kilogram (210,54 lei) on the line's massG. Without massG nothing can be computed. Fine-cut tobacco for rolling (1680,70 lei per kilogram) and heated-tobacco sticks are not distinguished"] else [])
  ++ (if g.consumption.any (fun s => s.good == .heatingOil) then ["5121: heating oil at the diesel rate, with 0,84 kg per litre assumed where the line gives no massG"] else [])
  ++ (if g.consumption.any (fun s => s.good == .gas) then ["5121: liquefied gas (position 2711: 4144 lei per tonne) is not modelled. Natural gas is not in anexa nr. 1"] else [])

def gOf (s : String) : CanonGlobal :=
  match Lean.Json.parse s with
  | .ok j => match parseGlobal j with | .ok g => g | .error _ => default
  | .error _ => default

def basket (line : String) : CanonGlobal :=
  gOf ("{\"id\":\"h\",\"schema\":\"global/2.0\",\"household\":{\"id\":\"h\",\"adults\":[{\"age\":40}]},\"consumption\":[" ++ line ++ "]}")

def dues (line : String) : List Int := (exciseCharges (basket line)).map (·.due)

#guard vat.embedded { good := .clothing, amount := 12000 } == 2000
#guard vat.embedded { good := .hotels, amount := 10800 } == 800
#guard vat.embedded { good := .medicines, amount := 10800 } == 800
#guard vat.embedded { good := .books, amount := 10000 } == 0
#guard vat.net { turnover := 1200000, sales := [{ good := .other, net := 1200000 }] } == 0
-- 100 litres of beer: 305 lei
#guard dues "{\"good\":\"beer\",\"amount\":5700,\"quantity\":100000,\"abvBp\":500}" == [305]
-- 10 litres of spirits at 40 %: 4 litres of absolute alcohol: 529,08 lei
#guard dues "{\"good\":\"spirits\",\"amount\":5700,\"quantity\":10000,\"abvBp\":4000}" == [529]
-- 1000 cigarettes sold for 3000 lei: 1081,43 + 13 % × 3000 = 1471,43 lei (above the minimum of 1450,48)
#guard dues "{\"good\":\"cigarettes\",\"amount\":3000,\"quantity\":1000000}" == [1471]
-- 1000 cigarettes sold for 2000 lei: 1081,43 + 260 = 1341,43, below the minimum: 1450,48 lei
#guard dues "{\"good\":\"cigarettes\",\"amount\":2000,\"quantity\":1000000}" == [1450]
-- 1000 litres of petrol at the assumed 0,75 kg per litre: 0,75 t × 8837,49 = 6628,12 lei
#guard dues "{\"good\":\"petrol\",\"amount\":25000,\"quantity\":1000000}" == [6628]
-- one tonne of diesel given by mass: 3718,64 lei, whole lei down
#guard dues "{\"good\":\"diesel\",\"amount\":25000,\"quantity\":1190000,\"massG\":1000000}" == [3718]
#guard dues "{\"good\":\"wine\",\"amount\":7600,\"quantity\":50000,\"abvBp\":1200}" == [0]
-- 10 litres of vermouth: 173,70 lei
#guard dues "{\"good\":\"wine\",\"sub\":\"vermouth\",\"amount\":2000,\"quantity\":10000,\"abvBp\":1600}" == [173]
-- 1000 litres of heating oil at the assumed 0,84 kg per litre: 0,84 t × 3718,64 = 3123,66 lei
#guard dues "{\"good\":\"heatingOil\",\"amount\":20000,\"quantity\":1000000}" == [3123]
-- 2 kg of pipe tobacco: 421,08 lei
#guard dues "{\"good\":\"tobaccoOther\",\"amount\":3000,\"quantity\":0,\"massG\":2000}" == [421]
#guard dues "{\"good\":\"tobaccoOther\",\"amount\":3000,\"quantity\":0}" == []

end MdGlobal.Consumption
