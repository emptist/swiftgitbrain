import Testing
@testable import GitBrainSwift
import Foundation

@Test
func testMemoryStoreSetAndGet() async {
    let memoryStore = MemoryStore()
    
    await memoryStore.set("test_key", value: SendableContent(["value": "test_value"]))
    let value = await memoryStore.get("test_key")
    
    #expect(value?.toAnyDict()["value"] as? String == "test_value")
}

@Test
func testMemoryStoreGetWithDefault() async {
    let memoryStore = MemoryStore()
    
    let value = await memoryStore.get("nonexistent", defaultValue: SendableContent(["value": "default"]))
    
    #expect(value?.toAnyDict()["value"] as? String == "default")
}

@Test
func testMemoryStoreExists() async {
    let memoryStore = MemoryStore()
    
    await memoryStore.set("test_key", value: SendableContent(["value": "test_value"]))
    
    #expect(await memoryStore.exists("test_key") == true)
    #expect(await memoryStore.exists("nonexistent") == false)
}

@Test
func testMemoryStoreDelete() async {
    let memoryStore = MemoryStore()
    
    await memoryStore.set("test_key", value: SendableContent(["value": "test_value"]))
    let deleted = await memoryStore.delete("test_key")
    
    #expect(deleted == true)
    #expect(await memoryStore.exists("test_key") == false)
}

@Test
func testMemoryStoreClear() async {
    let memoryStore = MemoryStore()
    
    await memoryStore.set("key1", value: SendableContent(["value": "value1"]))
    await memoryStore.set("key2", value: SendableContent(["value": "value2"]))
    await memoryStore.clear()
    
    #expect(await memoryStore.count() == 0)
}

@Test
func testMemoryStoreListKeys() async {
    let memoryStore = MemoryStore()
    
    await memoryStore.set("key1", value: SendableContent(["value": "value1"]))
    await memoryStore.set("key2", value: SendableContent(["value": "value2"]))
    await memoryStore.set("key3", value: SendableContent(["value": "value3"]))
    
    let keys = await memoryStore.listKeys()
    
    #expect(keys.count == 3)
    #expect(keys.contains("key1"))
    #expect(keys.contains("key2"))
    #expect(keys.contains("key3"))
}

@Test
func testMemoryStoreTimestamp() async {
    let memoryStore = MemoryStore()
    
    await memoryStore.set("test_key", value: SendableContent(["value": "test_value"]))
    let timestamp = await memoryStore.getTimestamp("test_key")
    
    #expect(timestamp != nil)
    #expect(timestamp! <= Date())
}
