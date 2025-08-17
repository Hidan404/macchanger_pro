import flet as ft
from backend import MacChanger

def start_app():
    def on_change_click(e):
        interface = interface_input.value
        new_mac = mac_input.value
        macchanger = MacChanger(interface, new_mac)
        result = macchanger.verificar_sistema()
        status.value = result
        page.update()

    page = ft.Page(title="MacChanger Pro", width=400, height=350)
    interface_input = ft.TextField(label="Interface de rede", placeholder="ex: eth0 ou Wi-Fi")
    mac_input = ft.TextField(label="Novo MAC", placeholder="AA:BB:CC:DD:EE:FF")
    status = ft.Text(value="")
    change_btn = ft.ElevatedButton("Alterar MAC", on_click=on_change_click)

    page.add(interface_input, mac_input, change_btn, status)
    page.start()
