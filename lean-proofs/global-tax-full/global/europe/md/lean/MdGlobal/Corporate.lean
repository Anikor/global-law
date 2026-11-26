import MdGlobal.Pit
import TaxKernel.Global2

/-!
# MD 2025: Impozitul pe venit (persoane juridice) (1200) and withholding on payments abroad

Source: Codul fiscal nr. 1163/1997, Titlul II, edition in force 01.01.2025, read on legis.md in a browser on 25 and 26
November 2026 (`https://www.legis.md/cautare/getResults?doc_id=138612&lang=ro`, legis.md answers 403 to scripts).
* art. 15 lit. b): "pentru persoanele juridice – în mărime de 12% din venitul impozabil"
* art. 15 lit. c): "pentru gospodăriile ţărăneşti (de fermier) – în mărime de 7% din venitul impozabil"
* capitolul 7¹ (art. 54¹-54⁴), companies not registered for VAT: art. 54² (1) "Obiect al impunerii este venitul
  determinat conform contabilităţii financiare, obţinut în perioada fiscală de declarare." and art. 54³ "Cota
  impozitului pe venit constituie 4% din obiectul impunerii."
* Titlul X, residents of IT parks: art. 369 (1) the object is "venitul din vînzări, înregistrat lunar în evidenţa
  contabilă", art. 370 (1) "Cota impozitului unic constituie 7% din obiectul impunerii, dar nu mai puţin decît suma
  minimă stabilită la alin.(2).", art. 370 (2) the minimum is, each month and for each employee, "30% din cuantumul
  salariului mediu lunar pe economie, prognozat pentru anul la care se referă perioada fiscală" (HG nr. 845/2024:
  16 100 lei, so 4 830 lei a month and 57 960 lei a year per employee)
* art. 372 (1): the single tax includes the income tax of the business, the income tax on wages, the employer's social
  contributions, the employees' health premiums, the local fees, the property tax and the road tax
* which regime a company is under is read from `company.sector`: `"farmHousehold"` (7 %), `"smallBusinessRegime"`
  (4 % of the income in the accounts, taken as the turnover), `"itPark"` (the single tax). No sector given: 12 %.
  These three names are the model's own, they are not among the kernel's agreed sector names.
* the IT-park minimum is computed for the year (12 months for every employee), the Code computes it month by month

## 1200 withholding on payments abroad
* art. 91 (1): "12% din plăţile direcţionate spre achitare nerezidentului aferente veniturilor de la art.71, cu
  excepţia celor specificate la art. 71 alin. (1) lit. a)", "6% din dividendele specificate la art. 71 alin. (1)
  lit. e)", "15% din dividende ... aferente profitului nerepartizat obţinut în perioadele fiscale 2008–2011 inclusiv"
* art. 71 (1): lit. e) dividends paid by a resident, lit. f) interest, lit. j) royalties, lit. b), b¹), r) services
* interest and royalties are Moldovan-source under lit. f), j) when paid by a resident, services under lit. b¹) when
  performed in Moldova: the model takes every payment abroad as Moldovan-source income

## From 1 January 2027 (not modelled)
Codul fiscal as in force 01.01.2027 (`doc_id=152862`, carrying Legea nr. 247/2026), read the same way, the model is for 2025 and does not apply these.
* art. 15: lit. c), the 7 % rate of farm households, is gone, lit. a) now names them at 12 % (+5 points). Lit. b),
  companies at 12 %, is unchanged.
* art. 91 (1) lit. c): "8% din dividende distribuite din profiturile generate începând cu perioada fiscală 2027"
  paid to non-residents (+2 points), lit. b) keeps 6 % for dividends from earlier profits, lit. a) keeps 12 % on other
  income of art. 71
* art. 90¹ (3¹) lit. b): the same 8 % on dividends paid to resident individuals
-/

namespace MdGlobal.Corporate
open TaxKernel TaxKernel.Global

def cit : CorpRegime :=
  { name := "Impozitul pe venit (persoane juridice)",   sched := Schedule.flat 1200 }

def citStatute : String := "Codul fiscal nr. 1163/1997 art. 15 lit. b) (12 %)"

/-- The regimes a company can be under, read from `company.sector` (the three names are the model's own). -/
def sectors (g : CanonGlobal) : List String := (companySectors g).getD []
def isItPark (g : CanonGlobal) : Bool := (sectors g).contains "itPark"
def isSmall (g : CanonGlobal) : Bool := !isItPark g && (sectors g).contains "smallBusinessRegime"
def isFarm (g : CanonGlobal) : Bool := !isItPark g && !isSmall g && (sectors g).contains "farmHousehold"

/-- art. 15 lit. c): farm households, 7 % of taxable income. -/
def farm : CorpRegime :=
  { name := "Impozitul pe venit (gospodării țărănești)", sched := Schedule.flat 700 }

def farmStatute : String := "Codul fiscal nr. 1163/1997 art. 15 lit. c) (7 %)"

/-- art. 54³: 4 % of the income in the accounts. -/
def smallTax (turnover : Int) : Int := divR .down (400 * pos turnover) BP

def smallStatute : String := "Codul fiscal art. 54² alin. (1), art. 54³ (4 % of the income in the accounts)"

/-- HG nr. 845/2024. -/
def avgSalary : Int := 16100

/-- art. 370 (2): 30 % of the average salary, each month, for each employee. -/
def itParkMinimum (employees : Nat) : Int := (employees : Int) * 12 * divR .down (3000 * avgSalary) BP

/-- art. 370 (1): 7 % of sales, not less than the minimum. -/
def itParkTax (turnover : Int) (employees : Nat) : Int := max (divR .down (700 * pos turnover) BP) (itParkMinimum employees)

def itParkStatute : String := "Codul fiscal art. 369 alin. (1), art. 370 alin. (1), (2) (7 % of sales, at least 30 % of the average salary a month per employee), HG nr. 845/2024"

def citCharges (g : CanonGlobal) : List Charge :=
  if isItPark g then
    [charge .cit "Impozitul unic de la rezidenții parcurilor pentru tehnologia informației" g.company.turnover id
      (fun t => itParkTax t g.company.employees) (statute := itParkStatute)]
  else if isSmall g then
    [charge .cit "Impozitul pe venit (agenți economici neînregistrați ca plătitori de T.V.A.)" g.company.turnover id
      smallTax (statute := smallStatute)]
  else if isFarm g then [farm.citCharge g.company farmStatute]
  else [cit.citCharge g.company citStatute]

/-- Codul fiscal art. 91 (1): dividends 6 %, other income of art. 71 12 %. -/
def p6wht : Wht :=
  { name := "withholding tax on payments abroad", rules := [
    { kind := .dividend, toCompany := none, minStakeBp := 0, rateBp := 600, statute := "Codul fiscal art. 91 alin. (1), art. 71 alin. (1) lit. e) (dividends 6 %)" },   { kind := .interest, toCompany := none, minStakeBp := 0, rateBp := 1200, statute := "Codul fiscal art. 91 alin. (1), art. 71 alin. (1) lit. f) (interest 12 %)" },   { kind := .royalty, toCompany := none, minStakeBp := 0, rateBp := 1200, statute := "Codul fiscal art. 91 alin. (1), art. 71 alin. (1) lit. j) (royalties 12 %)" }] }

/-- Codul fiscal art. 91 (1), art. 71 (1) lit. b), b¹), r): services. -/
def p9wht2 : Wht :=
  { name := "Impozit reținut la sursă (servicii)", rules := [
    { kind := .services, toCompany := none, minStakeBp := 0, rateBp := 1200, statute := "Codul fiscal art. 91 alin. (1), art. 71 alin. (1) lit. b), b¹), r) (services 12 %)" }] }

set_option linter.unusedVariables false in
def families : List Family :=
  [{ name := "1200 Impozitul pe venit (persoane juridice)", covers := [.cit],
     run := fun args g prev =>
       (if g.entity == .company then citCharges g else []) },
   { name := "1200 withholding on payments abroad (pass 6)", covers := [.cit],
     run := fun args g prev =>
       (if g.entity == .company then p6wht.charges g.company else []) },
   { name := "1200 Impozit reținut la sursă (servicii) (pass 9)", covers := [.cit],
     run := fun args g prev =>
       (if g.entity == .company then p9wht2.charges g.company else []) }]

def absent : List Absent :=
  []

def notes : List String := ["MD 1200: Codul fiscal art. 15, 71, 91 as in force 01.01.2025, read on legis.md (doc_id=138612)"]

set_option linter.unusedVariables false in
def unsupported (args : List String) (g : CanonGlobal) : List String :=
  (if g.entity == .company && (companySectors g).isNone then ["1200: no company.sector given, the general 12 % is applied. The 4 % regime (smallBusinessRegime), the 7 % rate of farm households (farmHousehold) and the single tax of IT-park residents (itPark) apply only when named"] else [])
  ++ (if g.entity == .company && isItPark g then ["1200 IT park: the minimum is taken for 12 months for every employee, the Code computes it month by month. The single tax replaces the taxes of art. 372 (1): the model drops the employer's social contributions, and the company's property tax and road tax are still booked if assets or vehicles are given"] else [])
  ++ (if g.entity == .company && isSmall g then ["1200 small-business regime: the conditions of art. 54¹ (not registered for VAT, the election) are not tested, and the income in the accounts is taken as the turnover"] else [])
  ++ (if g.entity == .company then ["group regimes, transfer pricing and treaties out of scope, deduction limits of Titlul II capitolul 3 not modelled"] else [])
  ++ (if g.entity == .company && g.company.paymentsAbroad.any (·.kind == .dividend) then ["1200 withholding: dividends from profits of 2008–2011 pay 15 % (art. 91 (1)), the 6 % rate is applied"] else [])
  ++ (if g.entity == .company && !g.company.paymentsAbroad.isEmpty then ["1200 withholding: every payment abroad is taken as Moldovan-source income of art. 71 (interest and royalties paid by a resident, services performed in Moldova)"] else [])

#guard cit.citTax { profit := 100000, turnover := 10000000 } == 12000
#guard cit.citTax { profit := 1000000, turnover := 10000000 } == 120000
#guard farm.citTax { profit := 100000, turnover := 1000000 } == 7000
#guard smallTax 1000000 == 40000
#guard itParkMinimum 10 == 579600
#guard itParkTax 20000000 10 == 1400000
#guard itParkTax 1000000 10 == 579600
#guard p6wht.amount { kind := .dividend, amount := 100000, toCompany := true, stakeBp := 0 } == 6000
#guard p6wht.amount { kind := .interest, amount := 100000, toCompany := true, stakeBp := 0 } == 12000
#guard p6wht.amount { kind := .royalty, amount := 100000, toCompany := true, stakeBp := 0 } == 12000
#guard p9wht2.amount { kind := .services, amount := 100000, toCompany := true, stakeBp := 0 } == 12000
#guard p9wht2.amount { kind := .services, amount := 100000, toCompany := false, stakeBp := 0 } == 12000

end MdGlobal.Corporate
