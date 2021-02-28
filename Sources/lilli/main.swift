import Lilliput


let driver = BasicDriver()
let engine = Engine(driver: driver)

engine.load(name: "test")
engine.run()
