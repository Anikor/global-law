import MdGlobal.Pit
import TaxKernel.Global2

/-!
# MD 2025: employer social contributions (2200), the employee's health premium (2100), fixed contributions of the
self-employed (2300)

Source: Legea nr. 489 din 08.07.1999 privind sistemul public de asigurări sociale, edition in force from 31.01.2024
(the one in force on 01.01.2025, the next is dated 18.07.2025), read on legis.md in a browser on 26 November 2026
(`https://www.legis.md/cautare/getResults?doc_id=139810&lang=ro`), its anexa nr. 1 is the file the page links
(`/UserFiles/Image/RO/2023/mo3-4md/an_1_489md.docx`).
* anexa nr. 1 pct. 1.1: "24% la suma salariilor și recompenselor calculate lunar pentru toți angajații – pentru
  angajatorii sectorului privat, instituțiilor de învățământ superior și ai instituțiilor medico-sanitare"
* the same point: 29 % for budget-funded authorities and institutions, pct. 1.2: 32 % (39 % public) for special
  working conditions, pct. 1.5: farm employers 24 %, of which 18 % from the employer and 6 % from the state budget,
  pct. 1.4: residents of IT parks under Legea nr. 77/2016
* the annex names no ceiling on the base

## 2100 Prima de asigurare obligatorie de asistență medicală (the employee)
Source: Legea fondurilor asigurării obligatorii de asistență medicală pe anul 2025 nr. 304 din 19.12.2024, edition in
force 01.01.2025 (`doc_id=146464`), and Legea nr. 1593/2002, edition in force 01.01.2025 (`doc_id=144917`), read on
legis.md in a browser on 26 November 2026.
* Legea nr. 304/2024 art. 4 (1): the premium as a percentage of wages for the payers of anexa nr. 1 to Legea nr.
  1593/2002 "se stabilește în mărime de 9,0%"
* Legea nr. 1593/2002 anexa nr. 1 pct. 2: the payers are "Angajaţii"
* Legea nr. 1593/2002 art. 6: computed on wages and other rewards before taxes are withheld
* the income-tax model (`MdTax`) does not deduct the premium, although its header records that the Code allows the
  deduction. The income tax it books on wages is therefore too high by 12 % of the premium.

## 2300 Fixed contributions of the self-employed
* Legea bugetului asigurărilor sociale de stat pe anul 2025 nr. 303 din 19.12.2024, edition in force 01.01.2025
  (`doc_id=146462`), art. 3 (1): the fixed annual contribution of the payers of pct. 1.6, 1.7 and 1.8 of anexa nr. 1
  to Legea nr. 489/1999 "se stabilește în mărime de 20518 lei"
* Legea nr. 489/1999 anexa nr. 1 pct. 1.6: founders of individual enterprises and farm households, independent
  retail traders, buyers of farm produce, other than pensioners and persons with disabilities
* Legea nr. 304/2024 art. 4 (2): the fixed health premium of the payers of anexa nr. 2 to Legea nr. 1593/2002 "se
  stabilește în mărime de 12636 de lei"
* Legea nr. 1593/2002 anexa nr. 2 pct. 1: persons who are not employed, among them lit. b) "fondatorii de
  întreprinderi individuale"
* input: an adult with self-employment income and no wages is taken as a founder of an individual enterprise who pays
  both fixed amounts in full. An adult with both wages and self-employment income is not decided and is listed.
* the reductions of the fixed health premium for early payment (Legea nr. 304/2024 art. 4 (3) to (6)) are not modelled

## From 1 January 2027 (not modelled)
* the edition in force 01.01.2027 (`doc_id=152737`) has a new anexa nr. 1 (Legea nr. 247/2026). Pct. 1.1 keeps "24% la
  suma salariilor și recompenselor calculate lunar pentru toți angajații", so the private-sector rate does not change,
  pct. 1.2 keeps 32 % and 39 % for special working conditions.
-/

namespace MdGlobal.Social
open TaxKernel TaxKernel.Global

def c0 : Contribution := { name := "Contribuții de asigurări sociale de stat obligatorii (angajator)", sched := Schedule.flat 2400, ceiling := -1 }

/-- Legea nr. 304/2024 art. 4 (1): the employee's health premium, 9 % of wages. -/
def health : Contribution := { name := "Prima de asigurare obligatorie de asistență medicală (angajat)", sched := Schedule.flat 900, ceiling := -1 }

def healthStatute : String := "Legea nr. 304/2024 art. 4 alin. (1) (9,0 %), Legea nr. 1593/2002 anexa nr. 1 pct. 2"

/-- Legea nr. 303/2024 art. 3 (1). -/
def fixedSocial : Int := 20518
/-- Legea nr. 304/2024 art. 4 (2). -/
def fixedHealth : Int := 12636

/-- An adult taken as a founder of an individual enterprise: self-employment income and no wages. -/
def selfEmployedOnly (a : Adult) : Bool := decide (0 < a.selfEmployment) && decide (a.wages ≤ 0)

def healthCharges (g : CanonGlobal) : List Charge :=
  if g.entity == .company then [] else
  (g.household.adults.zipIdx.filter (fun (a, _) => 0 < a.wages)).map fun (a, i) =>
    charge .sscEmployee health.name a.wages id (fun x => health.amount x) (event := s!"adult {i + 1}") (level := .social)
      (statute := healthStatute)

def selfCharges (g : CanonGlobal) : List Charge :=
  if g.entity == .company then [] else
  (g.household.adults.zipIdx.filter (fun (a, _) => selfEmployedOnly a)).flatMap fun (a, i) =>
    [flatCharge .sscSelf "Contribuția de asigurări sociale de stat în sumă fixă" fixedSocial (event := s!"adult {i + 1}")
       (level := .social) (statute := "Legea nr. 303/2024 art. 3 alin. (1) (20 518 lei), Legea nr. 489/1999 anexa nr. 1 pct. 1.6") (base := a.selfEmployment),
     flatCharge .sscSelf "Prima de asigurare obligatorie de asistență medicală în sumă fixă" fixedHealth (event := s!"adult {i + 1}")
       (level := .social) (statute := "Legea nr. 304/2024 art. 4 alin. (2) (12 636 lei), Legea nr. 1593/2002 anexa nr. 2 pct. 1 lit. b)") (base := a.selfEmployment)]

/-- A resident of an IT park pays the single tax instead (Codul fiscal art. 372 (1) lit. c)). -/
def itPark (g : CanonGlobal) : Bool := ((companySectors g).getD []).contains "itPark"

def contribs : List (Contribution × Oecd × String) :=
  [(c0, .sscEmployer, "Legea nr. 489/1999 anexa nr. 1 pct. 1.1: 24 % (private-sector employers)")]

/-- On the household's wages: each adult, each contribution (borne by the employer). -/
def householdCharges (g : CanonGlobal) : List Charge :=
  if g.entity == .company then [] else
  (g.household.adults.zipIdx.filter (fun (a, _) => 0 < a.wages)).flatMap fun (a, i) =>
    contribs.map fun (c, o, st) =>
      charge o c.name a.wages id (fun x => c.amount x) (event := s!"adult {i + 1}") (level := .social)
        (bearer := .employer) (statute := st)

/-- On a company's payroll (no ceiling, so the whole payroll at the rate). -/
def companyCharges (g : CanonGlobal) : List Charge :=
  if g.entity != .company || g.company.payroll ≤ 0 || itPark g then [] else
  contribs.map fun (c, o, st) =>
    charge o c.name g.company.payroll id (fun x => c.amount x) (event := "payroll") (level := .social)
      (statute := st)

set_option linter.unusedVariables false in
def families : List Family :=
  [{ name := "2200 employer social contributions", covers := [.sscEmployer],
     run := fun args g prev =>
       householdCharges g ++ companyCharges g },
   { name := "2100 employee health premium", covers := [.sscEmployee],
     run := fun args g prev => healthCharges g },
   { name := "2300 fixed contributions of the self-employed", covers := [.sscSelf],
     run := fun args g prev => selfCharges g }]

def absent : List Absent :=
  []

def notes : List String := ["MD 2200: Legea nr. 489/1999 anexa nr. 1, edition in force 01.01.2025, read on legis.md (doc_id=139810)", "MD 2100, 2300: Legea nr. 304/2024 (doc_id=146464), Legea nr. 303/2024 (doc_id=146462), Legea nr. 1593/2002 (doc_id=144917), editions in force 01.01.2025"]

set_option linter.unusedVariables false in
def unsupported (args : List String) (g : CanonGlobal) : List String :=
  (if (g.entity == .company && g.company.payroll > 0) || g.household.adults.any (fun a => 0 < a.wages) then ["2200: the private-sector rate of 24 % is applied, budget-funded employers (29 %), special working conditions (32 % / 39 %), farm employers (18 % + 6 % from the state budget) and IT-park residents (Legea nr. 77/2016) are not distinguished"] else [])
  ++ (if g.entity != .company && g.household.adults.any (fun a => 0 < a.wages) then ["2100: the health premium of 9 % is booked, but the income-tax model does not deduct it, so the 1100 income tax on wages is too high by 12 % of the premium"] else [])
  ++ (if g.entity != .company && g.household.adults.any selfEmployedOnly then ["2300: an adult with self-employment income and no wages is taken as a founder of an individual enterprise who pays the fixed social contribution and the fixed health premium in full. Pensioners, persons with disabilities, liberal professions (27 772 lei) and patent holders are not distinguished"] else [])
  ++ (if g.entity != .company && g.household.adults.any (fun a => 0 < a.selfEmployment && 0 < a.wages) then ["2300: an adult with both wages and self-employment income: whether the fixed contributions are due was not decided, none is booked (grade C)"] else [])

#guard c0.amount 50000 == 12000
#guard c0.amount 200000 == 48000
#guard health.amount 100000 == 9000
#guard selfEmployedOnly { age := 40, selfEmployment := 100000 } == true
#guard selfEmployedOnly { age := 40, selfEmployment := 100000, wages := 50000 } == false

end MdGlobal.Social
