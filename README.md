# Patrones de diseño más utilizados en Swift

## 1. Builder
El patrón Builder es un patrón de diseño de creación que le permite crear objetos complejos a partir de objetos simples paso a paso. Este patrón de diseño le ayuda a utilizar el mismo código para crear diferentes vistas de objetos.

Imagine un objeto complejo que requiere la inicialización incremental de varios campos y objetos anidados. Normalmente, el código de inicialización para tales objetos está oculto dentro de un gigantesco constructor con docenas de parámetros. O peor aún, puede estar esparcido por todo el código del cliente.

El patrón de diseño Builder requiere separar la construcción de un objeto de su propia clase. En cambio, la construcción de este objeto se asigna a objetos especiales llamados constructores y se divide en varios pasos. Para crear un objeto, llama sucesivamente a los métodos del constructor. Y no es necesario seguir todos los pasos, solo los necesarios para crear un objeto con una configuración particular.

### Debes aplicar el patrón de diseño Builder cuando…
Cuando quieres evitar el uso de un constructor telescópico (cuando un constructor tiene demasiados parámetros, se vuelve difícil de leer y administrar).
Cuando tu código necesita crear diferentes vistas de un objeto específico.
Cuando necesites componer objetos complejos.

### Ejemplo
Supongamos que estamos desarrollando una aplicación de iOS para un restaurante y necesita implementar la funcionalidad de pedidos. Puedes introducir dos estructuras, Plato y Pedido , y con la ayuda del objeto OrderBuilder , puedes componer pedidos con diferentes juegos de platos.

```
// Design Pattern: Builder

import Foundation

// Modelos
enum CategoriaPlato {
    case entradas, platoPrincipal, guarnisiones, bebidas
}

struct Plato {
    var nombre: String
    var precio: Float
}

struct ArticuloOrdenado {
    var plato: Plato
    var cuantos: Int
}

struct Orden {
    var entradas: [ArticuloOrdenado] = []
    var platoPrincipal: [ArticuloOrdenado] = []
    var guarnisiones: [ArticuloOrdenado] = []
    var bebidas: [ArticuloOrdenado] = []
    
    var precio: Float {
        let articulos = entradas + platoPrincipal + guarnisiones + bebidas
        return articulos.reduce(Float(0), { $0 + $1.plato.precio * Float($1.cuantos) })
    }
}

// Builder
class OrdenBuilder {
    private var orden: Orden?
    
    func resetear() {
        orden = Orden()
    }
    
    func setEntradas(plato: Plato) {
        set(plato: plato, con: orden?.entradas, conCategory: .entradas)
    }
    
    func setPlatoPrincipal(plato: Plato) {
        set(plato: plato, con: orden?.platoPrincipal, conCategory: .platoPrincipal)
    }
    
    func setGuarnisiones(plato: Plato) {
        set(plato: plato, con: orden?.guarnisiones, conCategory: .guarnisiones)
    }
    
    func setBebidas(plato: Plato) {
        set(plato: plato, con: orden?.bebidas, conCategory: .bebidas)
    }
    
    func getResultado() -> Orden? {
        return orden ?? nil
    }
    
    private func set(plato: Plato, con categoriaOrden: [ArticuloOrdenado]?, conCategory categoriaPlato: CategoriaPlato) {
        guard let categoriaOrdenDes = categoriaOrden else {
            return
        }
        
        var articulo: ArticuloOrdenado! = categoriaOrdenDes.filter( { $0.plato.nombre == plato.nombre }).first
        
        guard articulo == nil else {
            articulo.cuantos += 1
            return
        }
        
        articulo = ArticuloOrdenado(plato: plato, cuantos: 1)
        
        switch categoriaPlato {
        case .entradas:
            orden?.entradas.append(articulo)
        case .platoPrincipal:
            orden?.platoPrincipal.append(articulo)
        case .guarnisiones:
            orden?.guarnisiones.append(articulo)
        default:
            orden?.bebidas.append(articulo)
        }
        
        
    }
}


// Uso
let filete = Plato(nombre: "Filete", precio: 12.30)
let patatasFritas = Plato(nombre: "Patatas fritas", precio: 4.20)
let cerveza = Plato(nombre: "Cerveza", precio: 3.50)

let builder = OrdenBuilder()
builder.resetear()
builder.setPlatoPrincipal(plato: filete)
builder.setGuarnisiones(plato: patatasFritas)
builder.setBebidas(plato: cerveza)

let miOrden = builder.getResultado()
miOrden?.precio
```

## 2. Adapter

El adapter es un patrón de diseño estructural que permite que los objetos con interfaces incompatibles trabajen juntos. En otras palabras, transforma la interfaz de un objeto para adaptarlo a un objeto diferente.

Un adaptador envuelve un objeto, ocultándolo por completo de otro objeto. Por ejemplo, puede envolver un objeto que maneja medidores con un adaptador que convierte datos en pulgadas o centímetros.

### Debería utilizar el patrón de diseño del adapter cuando….
Cuando desea utilizar una clase de terceros pero su interfaz no coincide con el resto del código de su aplicación.
Cuando necesita usar varias subclases existentes pero carecen de una funcionalidad particular y, además, no puede extender la superclase.

### Ejemplo
Supongamos que deseas implementar una funcionalidad de gestión de eventos y calendario en tu aplicación iOS. Para hacer esto, debes integrar el framework de EventKit y adaptar el modelo de eventos del framework al modelo en tu aplicación. Un adapter puede envolver el modelo del framework y hacerlo compatible con el modelo de tu aplicación.

```
// Design Pattern: Adapter

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
```

## 3. Decorator

El patrón Decorator es un patrón de diseño estructural que te permite adjuntar dinámicamente nuevas funcionalidades a un objeto envolviéndolos en envoltorios(wrappers) útiles.

No es de extrañar que este patrón de diseño también se llame patrón de diseño Wrapper . Este nombre describe con más precisión la idea central detrás de este patrón: coloca un objeto de destino dentro de otro objeto contenedor que desencadena el comportamiento básico del objeto de destino y agrega su propio comportamiento al resultado.

Ambos objetos comparten la misma interfaz, por lo que al usuario no le importa con cuál de los objetos interactúan: limpio o envuelto. Puedes utilizar varios contenedores simultáneamente y obtener el comportamiento combinado de todos estos contenedores.

### Deberías usar el patrón de diseño Decorator cuando…….
Cuando desees agregar responsabilidades a los objetos de forma dinámica y ocultar esos objetos del código que los usa.
Cuando es imposible extender las responsabilidades de un objeto a través de la herencia.

### Ejemplo
Imagina que necesitas implementar la gestión de datos en su aplicación iOS. Puede crear dos decoradores: EncryptionDecorator para cifrar y descifrar datos y EncodingDecorator para codificar y decodificar.

```
// Design Patterns: Decorator

// Helpers

func encriptaString(miStringEncriptar: String, con claveEncriptacion: String) -> String {
    let stringBytes = [UInt8](miStringEncriptar.utf8)
    let claveBytes = [UInt8](claveEncriptacion.utf8)
    var encritacionBytes: [UInt8] = []
    
    for stringByte in stringBytes.enumerated() {
        encritacionBytes.append(stringByte.element ^ claveBytes[stringByte.offset % encritacionBytes.count])
    }
    
    return String(bytes: encritacionBytes, encoding: .utf8)!
}


func desencriptaString(myStringDesencriptar: String, con claveEncriptacion: String) -> String {
    let stringBytes = [UInt8](myStringDesencriptar.utf8)
    let claveBytes = [UInt8](claveEncriptacion.utf8)
    var desencriptacionBytes: [UInt8] = []
    
    for stringByte in stringBytes.enumerated() {
        desencriptacionBytes.append(stringByte.element ^ claveBytes[stringByte.offset % claveEncriptacion.count])
    }
    
    return String(bytes: desencriptacionBytes, encoding: .utf8)!
}

//Servicios

protocol DataSourcesProtocol: class {
    func escribeData(data: Any)
    func leeData() -> Any
}

class UserDefaultDataSource: DataSourcesProtocol {
    
    private let userDefaultsKey: String
    
    init(userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
    }
    
    func escribeData(data: Any) {
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    func leeData() -> Any {
        return UserDefaults.standard.value(forKey: userDefaultsKey) as Any
    }
}

// Decorator

class DataSourceDecorator: DataSourcesProtocol {
    
    let wrapper: DataSourcesProtocol
    
    init(pWrapper: DataSourcesProtocol) {
        self.wrapper = pWrapper
    }
    
    func escribeData(data: Any) {
        wrapper.escribeData(data: data)
    }
    
    func leeData() -> Any {
        wrapper.leeData()
    }
}

class EncodingDecorator: DataSourceDecorator {
    private let encodign: String.Encoding
    
    init(pWrapper: DataSourcesProtocol, pEncoding: String.Encoding) {
        self.encodign = pEncoding
        super.init(pWrapper: pWrapper)
    }
    
    override func escribeData(data: Any) {
        let stringData = (data as! String).data(using: encodign)!
        wrapper.escribeData(data: stringData)
    }
    
    override func leeData() -> Any {
        let data = wrapper.leeData() as! Data
        return String(data: data, encoding: encodign)!
    }
}

class EncryptationDecorator: DataSourceDecorator {
    private let claveEncriptacion: String
    
    init(pWrapper: DataSourcesProtocol, pClaveEncriptacion: String) {
        self.claveEncriptacion = pClaveEncriptacion
        super.init(pWrapper: pWrapper)
    }
    
    override func escribeData(data: Any) {
        let stringEncriptado = encriptaString(miStringEncriptar: data as! String, con: claveEncriptacion)
        wrapper.escribeData(data: stringEncriptado)
    }
    
    override func leeData() -> Any {
        let stringEncriptado = wrapper.leeData() as! String
        return desencriptaString(myStringDesencriptar: stringEncriptado, con: claveEncriptacion)
    }
}


// Uso

var source: DataSourcesProtocol = UserDefaultDataSource(userDefaultsKey: "decorator")
source = EncodingDecorator(pWrapper: source, pEncoding: .utf8)
source = EncryptationDecorator(pWrapper: source, pClaveEncriptacion: "secret")
source.escribeData(data: "Patrones de diseño")
source.leeData() as! String
```
