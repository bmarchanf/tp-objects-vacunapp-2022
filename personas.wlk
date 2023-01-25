import vacunas.*

class RegistroVacuna{
 	const property vacuna
 	const property fechaDeAplicacion
 	const property fechaDeVencimiento
 	
 	override method == (other) = vacuna == other.vacuna() && fechaDeAplicacion == other.fechaDeAplicacion() && fechaDeVencimiento == other.fechaDeVencimento() 
}
 
 class Persona{
 	const property nombre
 	var property edad
 	const property viveEn
 	var property anticuerpos
 	var property criterioEleccion = cualquierosa
 	var property historialDeVacunas = []
 	var property calendarioActual = calendario
 	
 	const localidadesEspeciales = ["Tierra del Fuego", "Santa Cruz", "Neuquen"]
 	
 	method esEspecial() = localidadesEspeciales.contains(viveEn)
 	
 	method buscarRegistro(vacuna) = historialDeVacunas.filter({registroVacuna => registroVacuna.vacuna() == vacuna})
 	 	
 	method vacunar(nuevaVacuna){
 		const hoy = calendarioActual.hoy()
 		anticuerpos = nuevaVacuna.efectoVacuna(self)
 		const nuevoRegistroDeVacuna = new RegistroVacuna(vacuna = nuevaVacuna,fechaDeAplicacion = hoy,fechaDeVencimiento = nuevaVacuna.fechaDeVencimiento(hoy,self) )
 		historialDeVacunas.add(nuevoRegistroDeVacuna)
 	}
 	
}
 
 object calendario{
 	method hoy() = new Date()
 }
 
 /*
cualquierosas: le da lo mismo cualquier vacuna 
  */
object cualquierosa{
	method elige(vacuna,persona) = true
}

/*
anticuerposas: eligen la vacuna si las deja con más de 100.000 anticuerpos.
 */
 
object anticuerposa{
	method elige(vacuna,persona) = vacuna.efectoVacuna(persona) > 100000
}

/*
inmunidosasFijas: eligen la vacuna si al 05/03/2022 todavía conservan la inmunidad. 
 */
object inmunidosasFijas{
	const property fechaTope = new Date(day=05, month=03, year=2023) 
	method elige(vacuna,persona) = vacuna.fechaDeVencimiento(calendario.hoy(), persona) >= fechaTope
}

/*
inmunidosasVariables: eligen la vacuna si después de x meses conservan la inmunidad.
La cantidad de meses se quiere parametrizar. 
 */
class InmunidosasVariables{
	const property mesesDeInmunidad
	method elige(vacuna,persona) = vacuna.fechaDeVencimiento(calendario.hoy(), persona) >= calendario.hoy().plusMonths(mesesDeInmunidad)
}
