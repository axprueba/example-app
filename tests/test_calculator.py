import pytest
from app.calculator import Calculator

def test_add():
    assert Calculator.add(2, 3) == 5
    assert Calculator.add(-1, 1) == 0
    assert Calculator.add(-1, -1) == -2

def test_subtract():
    assert Calculator.subtract(10, 5) == 5
    assert Calculator.subtract(-1, -1) == 0
    assert Calculator.subtract(0, 5) == -5

def test_multiply():
    assert Calculator.multiply(3, 5) == 15
    assert Calculator.multiply(-1, 5) == -5
    assert Calculator.multiply(0, 5) == 0

def test_divide():
    assert Calculator.divide(10, 2) == 5
    assert Calculator.divide(-10, 2) == -5
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        Calculator.divide(10, 0)