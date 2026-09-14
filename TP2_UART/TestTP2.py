import sys
import serial
from typing import Optional

BAUDRATE = 19200
SERIAL_PORT = "/dev/ttyUSB0"  # Verificar antes de usar

OPCODES = {
    "ADD": 0x20,
    "SUB": 0x22,
    "AND": 0x24,
    "OR":  0x25,
    "XOR": 0x26,
    "NOR": 0x27,
    "SRA": 0x03,
    "SRL": 0x02,
}

EXIT_COMMANDS = {"q", "e"}


class SerialPortControl:

    def __init__(self) -> None:
        try:
            self.serial_port = serial.Serial(
                port=SERIAL_PORT,
                baudrate=BAUDRATE,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                timeout=1
            )
        except serial.SerialException as e:
            print(f"Error al abrir el puerto serie: {e}")
            sys.exit(1)


    def send_serial_data(self) -> None:

        print("----------------------------------------------")
        print("Recordar presionar el botón de reset en placa antes de comenzar.")
        print(f"Puerto serie: {SERIAL_PORT}")
        print(f"Configuración: {BAUDRATE} baud, 8N1")
        print("----------------------------------------------")

        while True:

            operand1 = self.get_operand(
                "Ingrese el primer byte de datos: "
            )

            if operand1 is None:
                continue

            operand2 = self.get_operand(
                "Ingrese el segundo byte de datos: "
            )

            if operand2 is None:
                continue

            operation = self.get_operation()

            if operation is None:
                continue

            self.send_data(
                operand1,
                operand2,
                operation
            )

            self.receive_result()


    def get_operand(self, prompt: str) -> Optional[int]:

        operand_str = input(prompt).lower()

        if operand_str in EXIT_COMMANDS:
            self.exit_program()

        if (
            len(operand_str) == 8
            and all(c in "01" for c in operand_str)
        ):
            return int(operand_str, 2)

        print(
            "Error: por favor ingrese un número binario de 8 bits."
        )

        return None


    def get_operation(self) -> Optional[int]:

        operation = input(
            "Ingrese la operación "
            "ADD, SUB, AND, OR, XOR, NOR, SRA, SRL: "
        ).upper()

        if operation.lower() in EXIT_COMMANDS:
            self.exit_program()

        if operation in OPCODES:
            return OPCODES[operation]

        print("Operación inválida")

        return None


    def send_data(
        self,
        operand1: int,
        operand2: int,
        operation: int
    ) -> None:

        # uart_interface espera:
        # primer byte  -> A
        # segundo byte -> B
        # tercer byte  -> OP
        data_to_send = bytes([
            operand1,
            operand2,
            operation
        ])

        self.serial_port.reset_input_buffer()

        self.serial_port.write(data_to_send)
        self.serial_port.flush()


    def receive_result(self) -> None:

        received_data = self.serial_port.read(1)

        if len(received_data) == 1:

            result_unsigned = received_data[0]

            result_signed = (
                result_unsigned - 256
                if result_unsigned & 0x80
                else result_unsigned
            )

            binary_result = f"{result_unsigned:08b}"

            print(
                f"Resultado: {binary_result} "
                f"({result_signed})"
            )

        else:
            print(
                "Error de recepción: ningún dato recibido"
            )


    def exit_program(self) -> None:

        print("Saliendo...")

        self.serial_port.close()

        sys.exit()


if __name__ == "__main__":

    app = SerialPortControl()

    app.send_serial_data()