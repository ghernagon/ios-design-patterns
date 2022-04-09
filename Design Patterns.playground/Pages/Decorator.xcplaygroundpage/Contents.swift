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
