import personas.*

 class Vacuna{		
 	
 	method costoGeneral(persona)
 	
 	method costoExtra(persona)
 	
 	method costo(persona) = self.costoGeneral(persona)+ self.costoExtra(persona)
 	
 	method fechaDeVencimiento(fechaAplicacion,persona) 
 	
	method efectoVacuna(persona)
	
 }
 
/*Paifer: multiplica por 10 los anticuerpos de la persona a la que se le da la dosis, 
 otorga una inmunidad por 6 meses si la persona es mayor a 40 o 9 meses en caso contrario, siempre 
 contando desde el día de la aplicación.
 * 
 Paifer: le agrega un costo de $ 400 si la persona es menor a 18 años, o $ 100 en caso
 contrario. 
 */ 
 
 class VacunaSimple inherits Vacuna{
 	method costoPorSerMayorDe30(persona) =  0.max(persona.edad() -30)*50
 	
 	override method costoGeneral(persona) = 1000 + self.costoPorSerMayorDe30(persona)	
 }
 
 object paifer inherits VacunaSimple{	
 	
 	method mesesInmunidad(persona) = if (persona.edad() > 40) 6 else 9
 	
 	override method fechaDeVencimiento(fechaAplicacion,persona) = fechaAplicacion.plusMonths(self.mesesInmunidad(persona))

 	override method efectoVacuna(persona) = persona.anticuerpos() * 10
 	
 	override method costoExtra(persona) = if(persona.edad() < 18) 400 else 100
 	
 } 

class UserException inherits Exception {}
 
/*
Larussa: cada compuesto tiene un número que indica el efecto multiplicador 
de anticuerpos que da a la persona (hasta un máximo de 20x). Otorga una inmunidad hasta
el 03/03/2022.
Larussa: le incorpora $ 100 por el efecto multiplicador de los anticuerpos
* (contado en el punto 1)
 */ 
 
class LaRussa inherits VacunaSimple{	
	var property efectoMultiplicador
	const fechaDeCaducidad = new Date(day = 03,month = 03,year = 2023)
 	
 	method diasInmunidad(fechaAplicacion) = fechaDeCaducidad - fechaAplicacion
 	
 	override method fechaDeVencimiento(fechaAplicacion,persona) = fechaAplicacion.plusDays(self.diasInmunidad(fechaAplicacion))
 	
 	override method efectoVacuna(persona) = persona.anticuerpos() * efectoMultiplicador
 	
 	override method costoExtra(persona) = 100 * efectoMultiplicador	
 	
 }

/*
AstraLaVistaZeneca: suma 10.000 anticuerpos a la persona. La inmunidad que otorga es 6 meses
si la persona tiene un nombre par o 7 en caso contrario. 
* 
AstraLaVistaZeneca: le agrega $ 2.000 a las personas especiales, que son las que viven en
Tierra del Fuego, Santa Cruz o Neuquén, en caso contrario no tiene costo extra.
 */

object astraLaVistaZeneca inherits VacunaSimple{
	
	override method efectoVacuna(persona) = persona.anticuerpos() + 10000
	
	method nombrePar(persona) = persona.nombre().length().even()
	
	method mesesInmunidad(persona) = if(self.nombrePar(persona)) 6 else 7
	
	override method fechaDeVencimiento(fechaDeAplicacion, persona) = fechaDeAplicacion.plusMonths(self.mesesInmunidad(persona))
	
	override method costoExtra(persona) = if(persona.esEspecial()) 2000 else 0
}

/*
Combineta: es un compuesto que contiene varias dosis combinadas de alguna de las
anteriores (sabemos cuáles son). Considerar que otorga el mínimo de anticuerpos y el máximo de inmunidad de
todas las vacunas que conforman el combo. 
* 
Combineta: le aplica la sumatoria de todos los costos (ej: si el costo total de una Paifer fuera $ 1.400
y el costo de una Larussa fuera $ 1.500, el total sería $ 2.900). El costo extra suma 100 pesos por cada
vacuna.
 */
class Combineta inherits Vacuna{
	var property vacunas = []
	
	method vacunaMinimoAnticuerpos(persona) = vacunas.min({vacuna => vacuna.efectoVacuna(persona)})
	
	method vacunaMaximaInmunidad(fechaAplicacion,persona) = vacunas.max({vacuna => vacuna.fechaDeVencimiento(fechaAplicacion,persona)})
	
	override method fechaDeVencimiento(fechaAplicacion,persona) = self.vacunaMaximaInmunidad(fechaAplicacion,persona).fechaDeVencimiento(fechaAplicacion,persona)
	
	override method efectoVacuna(persona) = self.vacunaMinimoAnticuerpos(persona).efectoVacuna(persona)
	
	override method costoGeneral(persona) = vacunas.sum({vacuna => vacuna.costo(persona)})
	
	override method costoExtra(persona) = vacunas.size() * 100  
}

/*
Calcular cuánto saldría el plan inicial de vacunación, que consiste en conocer el total
en $ por aplicar la vacuna más barata que elegiría cada una de las personas. Las vacunas
actualmente disponibles son: paifer, larussa 5, larussa 2, astraLaVistaZeneca, y una
combineta de larussa 2 y paifer.
Aclaración: para saber qué vacuna aplicar a una persona si le viene bien más de una vacuna,
elegir la más barata.
*Si no le viene bien ninguna, no considerarla en el plan vacunatorio (son los outsiders,
por no decir otra cosa)
Si le viene bien una sola, obviamente es ésa
Punto 5: ¡Me llegó el turno! - todos los integrantes
Como vimos anteriormente las personas pueden aceptar o no la vacuna en base a su criterio.
Se pide modelar la confirmación del turno para la vacuna:  si el usuario la acepta se
le aplica la vacuna y agrega la vacuna a su historial, caso contrario se pide expresar
un mensaje adecuado en el sistema como por ejemplo “La vacuna solicitada no es aplicable
para la persona”.
*/

object planDeVacunacion{
	
	const laRussa5 = new LaRussa(efectoMultiplicador = 5)
	const laRussa2 = new LaRussa(efectoMultiplicador = 2)
	const combinacionPaiferLaRussa2 = [paifer,laRussa2]
	const combinetaPaiferLaRussa2 = new Combineta(vacunas = combinacionPaiferLaRussa2)
	
	const property vacunasDisponibles = [paifer,laRussa5,laRussa2,astraLaVistaZeneca,combinetaPaiferLaRussa2]
	
	var property personas = []
		
	method vacunasElegidas(persona) = vacunasDisponibles.filter({vacuna => persona.criterioEleccion().elige(vacuna,persona)})
	
	method vacunaMasBarata(persona) = self.vacunasElegidas(persona).min({vacuna => vacuna.costo(persona)})
	
	method vacunaAplicar(persona) = self.vacunaMasBarata(persona)
	
	method inconformista(persona) = self.vacunasElegidas(persona).isEmpty()
	
	method personasParticiparPlan() = personas.filter({persona => not self.inconformista(persona)})
	
	method vacunasAplicarPlan() = self.personasParticiparPlan().map({persona => self.vacunaAplicar(persona).costo(persona)})
	
	method costoPlanDeVacunacion() = self.vacunasAplicarPlan().sum()
	
	method confirmarTurno(persona) = if ((self.personasParticiparPlan()).contains(persona)) persona.vacunar(self.vacunaAplicar(persona)) else throw new UserException(message = "La vacuna indicada no es aplicable para la persona")
}
