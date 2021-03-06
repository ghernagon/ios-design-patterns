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

## 4. Facade

El patrón fachada es un patrón de diseño estructural que proporciona una interfaz simple a una biblioteca, framework o sistema complejo de clases.
Imagina que tu código tiene que lidiar con múltiples objetos de una biblioteca o framework complejo. Debe inicializar todos estos objetos, realizar un seguimiento del orden correcto de las dependencias, etc. Como resultado, la lógica de negocio de tus clases se entrelaza con los detalles de implementación de otras clases. Este código es difícil de leer y mantener.

El patrón Facade proporciona una interfaz simple para trabajar con subsistemas complejos que contienen muchas clases. Esta interfaz simplificada proporciona solo las funciones que necesita un cliente y oculta todas las demás.

### Deberías usar el patrón de diseño de Fachada cuando…….
Cuando desees proporcionar una interfaz simple o unificada a un subsistema complejo.
Cuando necesita descomponer un subsistema en capas separadas.

### Ejemplo
Muchas aplicaciones móviles modernas admiten la grabación y reproducción de audio, así que supongamos que necesita implementar esta funcionalidad. Puedes utilizar el patrón Facade para ocultar la implementación de los servicios responsables del sistema de archivos ( FileService ), las sesiones de audio ( AudioSessionService ), la grabación de audio ( RecorderService ) y la reproducción de audio ( PlayerService ). La Facade proporciona una interfaz simplificada para este sistema de clases bastante complejo.

```
// Design Patterns: Facade

import AVFoundation

// Service

struct FileService {
    private var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    var contentsOfDocumentsDirectory: [URL] {
        return try! FileManager.default.contentsOfDirectory(at: documentDirectory,
                                                            includingPropertiesForKeys: nil)
    }
    
    func path(withPathComponent component: String) -> URL {
        return documentDirectory.appendingPathComponent(component)
    }
    
    func removeItem(at index: Int) {
        let url = contentsOfDocumentsDirectory[index]
        try! FileManager.default.removeItem(at: url)
    }
}

protocol AudioSessionserviceDelegate: class {
    func audioSessionService(audioService: AudioSessionService, recordPermissionDidAllow allowed: Bool)
}

class AudioSessionService {
    
    weak var delegate: AudioSessionserviceDelegate?
    
    func setupSession() {
        try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try! AVAudioSession.sharedInstance().setActive(true)
        
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] (allowed) in
            DispatchQueue.main.async {
                guard let strongSelf = self, let delegate = strongSelf.delegate else {
                    return
                }
                delegate.audioSessionService(audioService: strongSelf, recordPermissionDidAllow: allowed)
            }
        }
    }
    
    func deactivateSession() {
        try! AVAudioSession.sharedInstance().setActive(false)
    }
}

struct RecordService {
    private var isRecording = false
    private var recorder: AVAudioRecorder!
    private var url: URL
    
    init(pUrl: URL) {
        self.url = pUrl
    }
    
    mutating func startRecord() {
        guard !isRecording else {
            return
        }
        
        isRecording = !isRecording
        recorder = try! AVAudioRecorder(url: url, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC])
        recorder.record()
    }
    
    mutating func stopRecord() {
        guard isRecording else {
            return
        }
        
        isRecording = !isRecording
        recorder.stop()
    }
}

protocol PlayerServiceDelegate: class {
    func playerService(playerService: PlayerService, playingDidFinish success: Bool)
}

class PlayerService: NSObject, AVAudioPlayerDelegate {
    
    private var player: AVAudioPlayer!
    private var url: URL
    weak var delegate: PlayerServiceDelegate?
    
    init(pUrl: URL) {
        self.url = pUrl
    }
    
    func startPlay() {
        player = try! AVAudioPlayer(contentsOf: url)
        player.delegate = self
        player.play()
    }
    
    func stopPlay() {
        player.stop()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.playerService(playerService: self, playingDidFinish: flag)
    }
}


// Facade

protocol AudioFacadeDelegate: class {
    func audioFacadePlayingDidFinish(audioFacade: AudioFacade)
}

class AudioFacade: PlayerServiceDelegate {
    
    private let audioSessionService = AudioSessionService()
    private let fileService = FileService()
    private let fileFormat = ".m4a"
    private var playerService: PlayerService!
    private var recorderService: RecordService!
    weak var delegate: AudioFacadeDelegate?
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        return dateFormatter
    }()
    
    init() {
        audioSessionService.setupSession()
    }
    
    deinit {
        audioSessionService.deactivateSession()
    }
    
    func startRecord() {
        let fileName = dateFormatter.string(from: Date()).appending(fileFormat)
        let url = fileService.path(withPathComponent: fileName)
        recorderService = RecordService(pUrl: url)
        recorderService.startRecord()
    }
    
    func stopRecord() {
        recorderService.stopRecord()
    }
    
    func numberOfRecords() -> Int {
        return fileService.contentsOfDocumentsDirectory.count
    }
    
    func nameOfRecord(at index: Int) -> String {
        let url = fileService.contentsOfDocumentsDirectory[index]
        return url.lastPathComponent
    }
    
    func removeRecord(at index: Int) {
        fileService.removeItem(at: index)
    }
    
    func playRecord(at index: Int) {
        let url = fileService.contentsOfDocumentsDirectory[index]
        playerService = PlayerService(pUrl: url)
        playerService.delegate = self
        playerService.startPlay()
    }
    
    func stopPlayRecord() {
        playerService.stopPlay()
    }
    
    func playerService(playerService: PlayerService, playingDidFinish success: Bool) {
        if success {
            delegate?.audioFacadePlayingDidFinish(audioFacade: self)
        }
    }
    
}

// Usage
let audioFacade = AudioFacade()
audioFacade.numberOfRecords()
```

## 5. Template Method

El patrón del Template Method es un patrón de diseño de comportamiento que define un esqueleto para un algoritmo y delega la responsabilidad de algunos pasos a las subclases. Este patrón permite que las subclases redefinan ciertos pasos de un algoritmo sin cambiar su estructura general.

Este patrón de diseño divide un algoritmo en una secuencia de pasos, describe estos pasos en métodos separados y los llama consecutivamente con la ayuda de un método de plantilla única.

### Debe utilizar el patrón de diseño del Método de plantilla cuando…
Cuando las subclases necesitan extender un algoritmo básico sin modificar su estructura.
Cuando tiene varias clases responsables de acciones bastante similares (lo que significa que cada vez que modifica una clase, necesita cambiar las otras clases).

### Ejemplo
Suponga que está trabajando en una aplicación de iOS que debe poder tomar y guardar fotografías. Por lo tanto, su aplicación necesita obtener permisos para usar la cámara y la galería de imágenes del iPhone (o iPad). Para hacer esto, puede usar la clase base PermissionService que tiene un algoritmo específico. Para obtener permiso para usar la cámara y la galería, puede crear dos subclases, CameraPermissionService y PhotoPermissionService , que redefinen ciertos pasos del algoritmo mientras mantienen los otros pasos iguales.

```
// Design Patterns: Template Method
import AVFoundation
import Photos

// Services
typealias AuthorizationCompletion = (status: Bool, message: String)

class PermissionService: NSObject {
    private var message: String = ""
    
    func authorize(_ completion: @escaping (AuthorizationCompletion) -> Void) {
        let status = checkStatus()
        
        guard !status else {
            complete(with: status, completion)
            return
        }
        
        requestAuthorization { [weak self] status in
            self?.complete(with: status, completion)
        }
    }

    func checkStatus() -> Bool {
        return false
    }
    
    func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        completion(false)
    }
    
    func formMessage(with status: Bool) {
        let messagePrefix = status ? "You have access to " : "You haven't access to "
        let nameOfCurrentPermissionService = String(describing: type(of: self))
        let nameOfBasePermissionService = String(describing: type(of: PermissionService.self))
        let messageSuffix = nameOfCurrentPermissionService.components(separatedBy: nameOfBasePermissionService).first!
        message = messagePrefix + messageSuffix
    }
    
    private func complete(with status: Bool, _ completion: @escaping (AuthorizationCompletion) -> Void) {
        formMessage(with: status)
        
        let result = (status: status, message: message)
        completion(result)
    }
}

class CameraPermissionService: PermissionService {
    override func checkStatus() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video).rawValue
        return status == AVAuthorizationStatus.authorized.rawValue
    }
    
    override func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { status in
            completion(status)
        }
    }
}

class PhotoPermissionService: PermissionService {
    override func checkStatus() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus().rawValue
        return status == PHAuthorizationStatus.authorized.rawValue
    }
    
    override func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            completion(status.rawValue == PHAuthorizationStatus.authorized.rawValue)
        }
    }
}

// Usage
let permissionServices = [CameraPermissionService(), PhotoPermissionService()]

for permissionService in permissionServices {
    permissionService.authorize { (_, message) in
        print(message)
    }
}
```

