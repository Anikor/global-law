import MdGlobal.Pit

/-!
# MD 2025: creșterea de capital (1100), gains of individuals on disposals

Source: Codul fiscal nr. 1163/1997, Titlul II capitolul 5 (art. 37-42), edition in force 01.01.2025, read on legis.md
in a browser on 25 and 26 November 2026 (`doc_id=138612`).
* art. 37: the chapter applies to individuals "care nu practică activitate de întreprinzător"
* art. 39 (1): capital assets are participations, bonds and other titles, private property not used in business,
  land, and options on them
* art. 40 (1): the gain or loss "este egală cu diferenţa dintre suma încasată (venitul obţinut) şi baza valorică a
  acestor active"
* art. 40 (5¹): not recognised for the disposal of "unui autoturism care a fost în proprietatea contribuabilului cel puțin 3 ani"
* art. 40 (6): "Creşterea sau pierderea de capital provenită din vînzare, schimb sau din altă formă de înstrăinare a
  locuinţei de bază nu este recunoscută în scopuri fiscale."
* art. 40 (7): "Suma creşterii de capital în perioada fiscală este egală cu 50% din suma excedentară a creşterii de
  capital recunoscute peste nivelul oricăror pierderi de capital suportate pe parcursul perioadei fiscale."
* art. 41 (1): capital losses are deductible only within capital gains
* art. 15 lit. a): the amount enters the individual's taxable income, taxed "în mărime de 12% din venitul anual
  impozabil"

## From 1 January 2027 (not modelled)
Codul fiscal as in force 01.01.2027 (`doc_id=152862`, carrying Legea nr. 247/2026), read the same way, the model is for 2025 and does not apply these.
* art. 40 (1): the gain "se impozitează la cota impozitului pe venit prevăzută la art. 15 lit. a)", and alin. (7), the
  50 % rule, is no longer in the article
* effect: the whole net gain is taxed at 12 %, so the tax on a gain doubles (a gain of 100 000 lei: 12 000 lei instead
  of 6 000 lei). The main-home and 3-year car rules of alin. (5¹), (6) stay.
* art. 33 (1): personal exemption 40 020 lei (29 700 in 2025, +10 320), art. 33 (2): 46 680 lei (34 620, +12 060),
  art. 35 (1): 11 040 lei per dependant (9 900, +1 140). These belong to the income-tax model (`MdTax`).
-/

namespace MdGlobal.Capital
open TaxKernel TaxKernel.Global

/-- art. 40 (5¹), (6): the main home, and a car owned for at least 3 years, are not recognised. -/
def recognised (d : Disposal) : Bool := !(d.mainHome || (d.kind == .vehicle && decide (36 ≤ d.heldMonths)))

def persons (ds : List Disposal) : List Nat := (ds.map (·.person)).eraseDups

/-- art. 40 (1), 41 (1): recognised gains less recognised losses of one person. -/
def net (ds : List Disposal) (p : Nat) : Int := isum (((ds.filter fun d => d.person == p && recognised d).map (·.gain)))

/-- art. 40 (7): 50 % of the excess of gains over losses. -/
def capitalGain (ds : List Disposal) (p : Nat) : Int := divR .down (5000 * pos (net ds p)) BP

/-- art. 15 lit. a): 12 %. -/
def tax (b : Int) : Int := (Schedule.flat 1200).tax {} b

def statute : String := "Codul fiscal art. 40 alin. (1), (5¹), (6), (7), art. 41 alin. (1), art. 15 lit. a) (12 %)"

def charges (g : CanonGlobal) : List Charge :=
  if g.entity == .company then [] else
  ((persons g.disposals).filter fun p => (g.disposals.any fun d => d.person == p && recognised d)).map fun p =>
    charge .pit "Impozitul pe venit: creșterea de capital" (net g.disposals p) (fun _ => capitalGain g.disposals p) tax
      (event := s!"disposals 2025, adult {p + 1}") (statute := statute)

set_option linter.unusedVariables false in
def families : List Family :=
  [{ name := "1100 Impozitul pe venit: creșterea de capital", covers := [],
     run := fun args g prev => charges g }]

def absent : List Absent :=
  []

def notes : List String := ["MD 1100 gains: Codul fiscal as in force 01.01.2025, read on legis.md (doc_id=138612)"]

set_option linter.unusedVariables false in
def unsupported (args : List String) (g : CanonGlobal) : List String :=
  (if g.entity == .household && !g.disposals.isEmpty then ["1100 gains: taxed at 12 % of the capital-gain amount, a personal exemption (art. 33-35) left unused by the person's other income is not set against it"] else [])
  ++ (if g.entity == .household && g.disposals.any (fun d => d.kind == .vehicle) then ["1100 gains: every asset of kind vehicle is taken as a car (autoturism), collection vehicles of art. 40 (5¹) are not distinguished"] else [])

#guard capitalGain [{ kind := .listedShares, proceeds := 150000, cost := 50000 }] 0 == 50000
#guard tax (capitalGain [{ kind := .listedShares, proceeds := 150000, cost := 50000 }] 0) == 6000
#guard capitalGain [{ kind := .listedShares, proceeds := 150000, cost := 50000 }, { kind := .land, proceeds := 10000, cost := 70000 }] 0 == 20000
#guard capitalGain [{ kind := .home, proceeds := 900000, cost := 400000, mainHome := true }] 0 == 0
#guard capitalGain [{ kind := .vehicle, proceeds := 90000, cost := 40000, heldMonths := 36 }] 0 == 0
#guard capitalGain [{ kind := .vehicle, proceeds := 90000, cost := 40000, heldMonths := 35 }] 0 == 25000
#guard capitalGain [{ kind := .listedShares, proceeds := 50000, cost := 150000 }] 0 == 0

end MdGlobal.Capital
