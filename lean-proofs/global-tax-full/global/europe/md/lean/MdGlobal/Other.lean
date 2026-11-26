import MdGlobal.Pit
import TaxKernel.Global2

/-!
# MD 2025: taxa pentru folosirea drumurilor de către autovehiculele înmatriculate în Republica Moldova (5200),
other taxes of the Code (6000) not modelled

Source: Codul fiscal nr. 1163/1997, Titlul IX capitolul 2 (art. 337-343) and its anexa nr. 1, and art. 6, edition in
force 01.01.2025, read on legis.md in a browser on 25 and 26 November 2026 (`doc_id=138612`).

## 5200 Taxa pentru folosirea drumurilor
* art. 337: "Subiecţi ai impunerii sînt persoanele fizice şi persoanele juridice posesoare de autovehicule
  înmatriculate în Republica Moldova."
* art. 339 (1): "Cotele taxei se stabilesc conform anexei nr.1 la prezentul titlu."
* art. 340 (2): "Taxa se achită pentru perioada fiscală printr-o plată unică şi în volum deplin"
* anexa nr. 1 pct. 1: motorcycles, mopeds, scooters: up to 500 cm³ inclusive 300 lei, above 500 cm³ 600 lei
* anexa nr. 1 pct. 2: cars, by engine capacity, per cm³: up to 2000 cm³ inclusive 0,60 lei, 2001 to 3000 cm³ 0,90,
  3001 to 4000 cm³ 1,2, 4001 to 5000 cm³ 1,5, above 5001 cm³ 1,8
* reading taken: the rate of the car's band applies to its whole engine capacity (1600 cm³: 960 lei, 2500 cm³: 2250 lei)
* anexa nr. 1 pct. 5: road tractors ("Autoremorchere, tractoare") 2250 lei
* anexa nr. 1 pct. 6: lorries and other self-propelled vehicles, "cu masa totală": up to 1,6 t 1200 lei, from 1,6 t to
  5,0 t 2250 lei, from 5,0 t to 10,0 t 3000 lei, above 10,0 t 4500 lei
* anexa nr. 1 pct. 7: buses by seats, "Numărul de locuri se calculează fără locul şoferului.": up to 11 seats
  2925 lei, 12 to 17 seats 3600 lei, 18 to 24 seats 4275 lei, 25 to 40 seats 4725 lei, above 40 seats 5400 lei
* input: `vehicleKind` `"lorry"` with `massKg` (the total mass), `"bus"` with `seats` (without the driver's),
  `"tractor"`. These kind names are the model's own.
* anexa nr. 1 pct. 3, 4: trailers 270 lei and semi-trailers 225 lei per tonne of load capacity (semi-trailers above
  20 t: 4500 lei) are not modelled, because the input has no load capacity
* art. 343: persons with locomotor disabilities are exempt (not in the input)
* a car with no engine capacity (an electric car) has no row in pct. 2: no charge is booked and the vehicle is listed

## Later editions (not modelled)
* the editions in force 01.11.2026 and 01.01.2027 (`doc_id=157079`, `152862`) add rows for electric vehicles, which the
  2025 annex lacks: pct. 1¹ electric mopeds and scooters 300 lei, electric motorcycles 600 lei, pct. 2¹ fully electric
  cars by total mass: up to 1500 kg 0,60 lei/kg, 1501 to 2500 kg 0,90 lei/kg, 2501 to 3500 kg 1,20 lei/kg, 3501 to
  4500 kg 1,50 lei/kg. The rates of pct. 1 and 2 for 2027 are those of 2025.
* art. 6 (5) in the 2027 edition drops "impozitul privat" and adds "taxa de viciu" and a charge on postal parcels

## 6000 Other taxes: read, not modelled
* art. 6 (5), state taxes: lit. a) "impozitul pe venit", b) "taxa pe valoarea adăugată", c) "accizele", d) "impozitul
  privat", e) "taxa vamală", f) "taxele rutiere", g) "impozitul pe avere", h) "impozitul unic de la rezidenţii
  parcurilor pentru tehnologia informaţiei"
* art. 6 (6), local taxes: property tax, natural-resource charges (Titlul VIII) and the local fees of Titlul VII
* not modelled: impozitul privat, the local fees, the natural-resource charges, the vignette for vehicles not
  registered in Moldova (Titlul IX capitolul 3) and the single tax of IT-park residents (Titlul X art. 370 (1): "7% din
  obiectul impunerii")
-/

namespace MdGlobal.Other
open TaxKernel TaxKernel.Global

def roadName : String := "Taxa pentru folosirea drumurilor"

def carStatute (row : String) : String := s!"Codul fiscal art. 339 alin. (1), anexa nr. 1 la titlul IX pct. 2 lit. {row}"

/-- A car whose engine capacity is in `(lo, hi]`: `num / 100` lei per cm³ of the whole capacity. -/
def car (lo hi num : Int) (row : String) : VehicleTax :=
  { name := roadName, kinds := ["car"], when := [(.engineCcm, lo, hi)],
    parts := [(.engineCcm, QtyTable.perUnit num 100)], proRata := false, statute := carStatute row }

def moto (lo hi amount : Int) (row : String) : VehicleTax :=
  { name := roadName, kinds := ["motorcycle"], when := [(.engineCcm, lo, hi)], fixed := amount, proRata := false,
    statute := s!"Codul fiscal art. 339 alin. (1), anexa nr. 1 la titlul IX pct. 1 lit. {row}" }

/-- pct. 6: a lorry whose total mass is in `(lo, hi]` kg. -/
def lorry (lo hi amount : Int) (row : String) : VehicleTax :=
  { name := roadName, kinds := ["lorry"], when := [(.massKg, lo, hi)], fixed := amount, proRata := false,
    statute := s!"Codul fiscal art. 339 alin. (1), anexa nr. 1 la titlul IX pct. 6 lit. {row}" }

/-- pct. 7: a bus whose seats (without the driver's) are in `(lo, hi]`. -/
def bus (lo hi amount : Int) (row : String) : VehicleTax :=
  { name := roadName, kinds := ["bus"], when := [(.seats, lo, hi)], fixed := amount, proRata := false,
    statute := s!"Codul fiscal art. 339 alin. (1), anexa nr. 1 la titlul IX pct. 7 lit. {row}" }

/-- pct. 5: road tractors. -/
def tractor : VehicleTax :=
  { name := roadName, kinds := ["tractor"], fixed := 2250, proRata := false,
    statute := "Codul fiscal art. 339 alin. (1), anexa nr. 1 la titlul IX pct. 5" }

def roadTaxes : List VehicleTax :=
  [car (-1) 2000 60 "a)", car 2000 3000 90 "b)", car 3000 4000 120 "c)", car 4000 5000 150 "d)", car 5000 (-1) 180 "e)",
   moto (-1) 500 300 "a)", moto 500 (-1) 600 "b)",
   lorry (-1) 1600 1200 "a)", lorry 1600 5000 2250 "b)", lorry 5000 10000 3000 "c)", lorry 10000 (-1) 4500 "d)",
   bus (-1) 11 2925 "a)", bus 11 17 3600 "b)", bus 17 24 4275 "c)", bus 24 40 4725 "d)", bus 40 (-1) 5400 "e)",
   tractor]

def families : List Family := [vehicleTaxFamily roadName roadTaxes]

def absent : List Absent :=
  []

def notes : List String := ["MD 5200: Codul fiscal Titlul IX anexa nr. 1 as in force 01.01.2025, read on legis.md (doc_id=138612)"]

set_option linter.unusedVariables false in
def unsupported (args : List String) (g : CanonGlobal) : List String :=
  vehicleTaxUnknown roadName roadTaxes g
  ++ vehicleTaxUnmatched roadName roadTaxes g
  ++ (if true then ["6000 Other taxes: not modelled (grade C: Codul fiscal art. 6 (5), (6) read, impozitul privat, the local fees of Titlul VII, the natural-resource charges of Titlul VIII and the single tax of IT-park residents are not modelled)"] else [])

def gOf (s : String) : CanonGlobal :=
  match Lean.Json.parse s with
  | .ok j => match parseGlobal j with | .ok g => g | .error _ => default
  | .error _ => default

def veh (v : String) : CanonGlobal :=
  gOf ("{\"id\":\"h\",\"schema\":\"global/2.0\",\"year\":2025,\"household\":{\"id\":\"h\",\"adults\":[{\"age\":40}]},\"assets\":[" ++ v ++ "]}")

def dues (v : String) : List Int := (vehicleTaxCharges roadTaxes (veh v)).map (·.due)

#guard dues "{\"kind\":\"vehicle\",\"value\":100000,\"vehicleKind\":\"car\",\"engineCcm\":1600,\"fuel\":\"petrol\"}" == [960]
#guard dues "{\"kind\":\"vehicle\",\"value\":100000,\"vehicleKind\":\"car\",\"engineCcm\":2000,\"fuel\":\"petrol\"}" == [1200]
#guard dues "{\"kind\":\"vehicle\",\"value\":100000,\"vehicleKind\":\"car\",\"engineCcm\":2001,\"fuel\":\"diesel\"}" == [1800]
#guard dues "{\"kind\":\"vehicle\",\"value\":100000,\"vehicleKind\":\"car\",\"engineCcm\":2500,\"fuel\":\"diesel\"}" == [2250]
#guard dues "{\"kind\":\"vehicle\",\"value\":100000,\"vehicleKind\":\"car\",\"engineCcm\":5500,\"fuel\":\"petrol\"}" == [9900]
#guard dues "{\"kind\":\"vehicle\",\"value\":100000,\"vehicleKind\":\"car\",\"engineCcm\":1600,\"fuel\":\"petrol\",\"months\":6}" == [960]
#guard dues "{\"kind\":\"vehicle\",\"value\":30000,\"vehicleKind\":\"motorcycle\",\"engineCcm\":650,\"fuel\":\"petrol\"}" == [600]
#guard dues "{\"kind\":\"vehicle\",\"value\":300000,\"vehicleKind\":\"car\",\"fuel\":\"electric\"}" == []
#guard dues "{\"kind\":\"vehicle\",\"value\":300000,\"vehicleKind\":\"lorry\",\"massKg\":1600,\"fuel\":\"diesel\"}" == [1200]
#guard dues "{\"kind\":\"vehicle\",\"value\":300000,\"vehicleKind\":\"lorry\",\"massKg\":3500,\"fuel\":\"diesel\"}" == [2250]
#guard dues "{\"kind\":\"vehicle\",\"value\":300000,\"vehicleKind\":\"lorry\",\"massKg\":18000,\"fuel\":\"diesel\"}" == [4500]
#guard dues "{\"kind\":\"vehicle\",\"value\":300000,\"vehicleKind\":\"bus\",\"seats\":17,\"fuel\":\"diesel\"}" == [3600]
#guard dues "{\"kind\":\"vehicle\",\"value\":300000,\"vehicleKind\":\"bus\",\"seats\":50,\"fuel\":\"diesel\"}" == [5400]
#guard dues "{\"kind\":\"vehicle\",\"value\":300000,\"vehicleKind\":\"tractor\",\"fuel\":\"diesel\"}" == [2250]
#guard (vehicleTaxUnknown roadName roadTaxes (veh "{\"kind\":\"vehicle\",\"value\":300000,\"vehicleKind\":\"car\",\"fuel\":\"electric\"}")).length + (vehicleTaxUnmatched roadName roadTaxes (veh "{\"kind\":\"vehicle\",\"value\":300000,\"vehicleKind\":\"car\",\"fuel\":\"electric\"}")).length == 1

end MdGlobal.Other
