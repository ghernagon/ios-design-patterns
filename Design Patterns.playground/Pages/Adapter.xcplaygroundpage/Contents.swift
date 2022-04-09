// Design Pattern Adapter

import EventKit


//Modelos

protocol EventosProtocol: class {
    var titulo: String { get }
    var fechaInicio: String { get }
    var fechaFin: String { get }
}

extension EventosProtocol {
    var description: String {
        return "Nombre \(titulo)\n inicia: \(fechaInicio)\n finaliza: \(fechaFin)"
    }
}

class EventoLocal: EventosProtocol {
    var titulo: String
    var fechaInicio: String
    var fechaFin: String
    
    init(pTitulo: String, pFechaInicio: String, pFechaFin: String) {
        self.titulo = pTitulo
        self.fechaInicio = pFechaInicio
        self.fechaFin = pFechaFin
    }
}

// Adapter

class EKEventAdapter: EventosProtocol {
    
    private var evento: EKEvent
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormatter
    }()
    
    var titulo: String {
        return evento.title
    }
    
    var fechaInicio: String {
        return dateFormatter.string(from: evento.startDate)
    }
    
    var fechaFin: String {
        return dateFormatter.string(from: evento.endDate)
    }
    
    init(evento: EKEvent) {
        self.evento = evento
    }
}

// Uso

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"

let eventosStore = EKEventStore()
let evento = EKEvent(eventStore: eventosStore)
evento.title = "Twitch con @devswiftlover y @alfonsomiranda"
evento.startDate = dateFormatter.date(from: "04/09/2021 18:00")
evento.endDate = dateFormatter.date(from: "04/09/2021 20:00")

let adapter = EKEventAdapter(evento: evento)
adapter.description
