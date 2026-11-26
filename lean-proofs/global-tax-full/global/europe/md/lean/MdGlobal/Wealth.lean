import MdGlobal.Pit
import TaxKernel.Global2

/-!
# MD 2025: Impozitul pe avere (4200), no inheritance or gift tax (4300)

Source: Codul fiscal nr. 1163/1997, edition in force 01.01.2025, read on legis.md in a browser on 25 and 26 November
2026 (`https://www.legis.md/cautare/getResults?doc_id=138612&lang=ro`, legis.md answers 403 to scripts).

## 4200 Impozitul pe avere (Titlul VI¹, art. 287¹-287⁷)
* art. 287² (1): "Subiecţi ai impunerii sînt persoanele fizice proprietari ai bunurilor imobiliare cu destinaţie
  locativă, inclusiv casele de vacanţă (cu excepţia terenurilor)"
* art. 287³ (1): the property whose total "întruneşte cumulativ următoarele condiţii": lit. a) "valoarea estimată
  totală constituie cel puțin 200 de salarii medii lunare pe economie prognozate și aprobate de Guvern pentru perioada
  pentru care se calculează impozitul", lit. b) "suprafaţa totală constituie 120 m2 şi mai mult."
* art. 287³ (4): the base is the value estimated by the cadastral bodies, art. 287⁴: "Cota impozitului reprezintă
  0,8% din baza impozabilă."
* the average salary: Hotărârea Guvernului nr. 845 din 18.12.2024 (`doc_id=146269`): "în mărime de 16 100 de lei",
  200 × 16 100 = 3 220 000 lei
* reading taken: the two conditions of alin. (1) are cumulative, as its text says. Alin. (3) (not an object when the
  value is below the floor "și" the area is below 120 m²) is not read as taxing a holding that meets only one.
* input: assets of kind `home` and `realEstate` are taken as residential, their floor area is the asset's `"areaM2"`

## From 1 January 2027 (not modelled)
Codul fiscal as in force 01.01.2027 (`doc_id=152862`, carrying Legea nr. 247/2026), read the same way, the model is for 2025 and does not apply these.
* art. 287³: the object is residential property "a căror valoare estimată totală constituie cel puțin 4 milioane de lei
  conform situației existente la data de 1 noiembrie a anului de gestiune", the 120 m² condition is gone
* art. 287⁴: "Cota impozitului reprezintă 0,8% din cuantumul ce depășește plafonul prevăzut la art. 2873." (the page
  prints art. 287³ as "art. 2873")
* effect: the threshold rises from 3 220 000 lei (2025) to 4 000 000 lei, and the tax falls on the excess only. A home
  estimated at 5 000 000 lei pays 8 000 lei instead of 40 000 lei.

## 4300 not levied
* art. 20 lit. i): non-taxable income includes "patrimoniul primit de către persoanele fizice cetăţeni ai Republicii
  Moldova cu titlu de donaţie sau de moştenire, cu excepţia donaţiilor efectuate conform art.90¹ alin.(3¹)"
* art. 90¹ (3¹): the exception is an income tax (1100) withheld by the payers of art. 90: "6% din mărimea sumei
  mijloacelor băneşti donate persoanelor fizice care nu desfăşoară activitate de întreprinzător"
-/

namespace MdGlobal.Wealth
open TaxKernel TaxKernel.Global

/-- HG nr. 845/2024: the forecast average monthly salary for 2025. -/
def avgSalary : Int := 16100
/-- art. 287³ (1) a): 200 average salaries. -/
def valueFloor : Int := 200 * avgSalary
/-- art. 287³ (1) b): 120 m². -/
def areaFloor : Int := 120

def residential (a : Asset) : Bool := a.kind == .home || a.kind == .realEstate

/-- The residential holdings of one person, each with its position in `assets`. -/
def holdings (g : CanonGlobal) (p : Nat) : List (Asset × Nat) :=
  g.assets.zipIdx.filter fun (a, _) => residential a && a.person == p

def persons (g : CanonGlobal) : List Nat := ((g.assets.filter residential).map (·.person)).eraseDups

def totalValue (g : CanonGlobal) (p : Nat) : Int := isum ((holdings g p).map (·.1.statutoryValue))
def areaKnown (g : CanonGlobal) (p : Nat) : Bool := (holdings g p).all fun (_, i) => 0 < assetAreaM2 g i
def totalArea (g : CanonGlobal) (p : Nat) : Int := isum ((holdings g p).map fun (_, i) => assetAreaM2 g i)

/-- art. 287³ (1): both conditions. -/
def liable (g : CanonGlobal) (p : Nat) : Bool :=
  decide (valueFloor ≤ totalValue g p) && areaKnown g p && decide (areaFloor ≤ totalArea g p)

/-- art. 287⁴: 0,8 % of the base. -/
def tax (v : Int) : Int := divR .down (80 * pos v) BP

def statute : String := "Codul fiscal art. 287³ alin. (1), (4), art. 287⁴ (0,8 %), HG nr. 845/2024 (16 100 lei)"

def charges (g : CanonGlobal) : List Charge :=
  if g.entity == .company then [] else
  ((persons g).filter (liable g)).map fun p =>
    charge .wealth "Impozitul pe avere" (totalValue g p) id tax (event := s!"adult {p + 1}") (statute := statute)

set_option linter.unusedVariables false in
def families : List Family :=
  [{ name := "4200 Impozitul pe avere", covers := [.wealth],
     run := fun args g prev => charges g }]

def absent : List Absent :=
  [{ oecd := .estate, why := "no inheritance or gift tax: Codul fiscal art. 20 lit. i) (property received by citizens as a gift or inheritance is non-taxable income), a 6 % income tax is withheld on money donated by the payers of art. 90 (art. 90¹ alin. (3¹), heading 1100)" }]

def notes : List String := ["MD 4200, 4300: Codul fiscal as in force 01.01.2025, read on legis.md (doc_id=138612), HG nr. 845/2024 (doc_id=146269)"]

set_option linter.unusedVariables false in
def unsupported (args : List String) (g : CanonGlobal) : List String :=
  (if g.entity != .company && (persons g).any (fun p => decide (valueFloor ≤ totalValue g p) && !areaKnown g p) then ["4200 Impozitul pe avere: residential property worth 3 220 000 lei or more, floor area (areaM2) not given: the 120 m² condition of art. 287³ (1) b) cannot be tested (grade C)"] else [])
  ++ (if g.entity != .company && g.assets.any (·.kind == .realEstate) then ["4200 Impozitul pe avere: assets of kind realEstate are taken as residential (art. 287¹ pct. 3), 4)), joint ownership (art. 287² (2), (3)) follows the asset's person"] else [])
  ++ (if g.transfers.any (·.kind == .gift) then ["1100: 6 % withheld on money donated to an individual by a payer of art. 90 (art. 90¹ alin. (3¹)): the donor is not in the input"] else [])

def gOf (s : String) : CanonGlobal :=
  match Lean.Json.parse s with
  | .ok j => match parseGlobal j with | .ok g => g | .error _ => default
  | .error _ => default

#guard valueFloor == 3220000
#guard tax 4000000 == 32000
#guard ((charges (gOf "{\"id\":\"h\",\"schema\":\"global/2.0\",\"household\":{\"id\":\"h\",\"adults\":[{\"age\":40}]},\"assets\":[{\"kind\":\"home\",\"value\":5000000,\"assessed\":4000000,\"areaM2\":150}]}")).map (·.due)) == [32000]
#guard (charges (gOf "{\"id\":\"h\",\"schema\":\"global/2.0\",\"household\":{\"id\":\"h\",\"adults\":[{\"age\":40}]},\"assets\":[{\"kind\":\"home\",\"value\":5000000,\"assessed\":4000000,\"areaM2\":100}]}")).isEmpty
#guard (charges (gOf "{\"id\":\"h\",\"schema\":\"global/2.0\",\"household\":{\"id\":\"h\",\"adults\":[{\"age\":40}]},\"assets\":[{\"kind\":\"home\",\"value\":3000000,\"areaM2\":200}]}")).isEmpty
#guard (charges (gOf "{\"id\":\"h\",\"schema\":\"global/2.0\",\"household\":{\"id\":\"h\",\"adults\":[{\"age\":40}]},\"assets\":[{\"kind\":\"home\",\"value\":4000000}]}")).isEmpty

end MdGlobal.Wealth
