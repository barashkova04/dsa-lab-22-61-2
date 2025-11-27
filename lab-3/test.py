"""
Tests for quadratic equation solver.
"""

import quadratic


class TestQuadraticPositive:
    """Positive tests - when discriminant >= 0."""
    
    def test_discriminant_positive(self):
        """Test for case D > 0."""
        result = quadratic.calculate_discriminant(1, -3, 2)
        assert result == 1
        
    def test_discriminant_zero(self):
        """Test for case D = 0."""
        result = quadratic.calculate_discriminant(1, -2, 1)
        assert result == 0
        
    def test_discriminant_another_positive(self):
        """Another test for D > 0."""
        result = quadratic.calculate_discriminant(2, 5, -3)
        assert result == 49


class TestQuadraticNegative:
    """Negative tests - when discriminant < 0."""
    
    def test_discriminant_negative(self):
        """Test for case D < 0."""
        result = quadratic.calculate_discriminant(1, 1, 1)
        assert result == -3
        
    def test_discriminant_another_negative(self):
        """Another test for D < 0."""
        result = quadratic.calculate_discriminant(3, -2, 5)
        assert result == -56


class TestSolveQuadratic:
    """Tests for solving quadratic equation."""
    
    def test_solve_two_roots(self):
        """Test for two roots (D > 0)."""
        roots = quadratic.solve_quadratic(1, -3, 2)
        assert roots == (2.0, 1.0)
        
    def test_solve_one_root(self):
        """Test for one root (D = 0)."""
        roots = quadratic.solve_quadratic(1, -2, 1)
        assert roots == (1.0,)
        
    def test_solve_no_real_roots(self):
        """Test for no real roots (D < 0)."""
        roots = quadratic.solve_quadratic(1, 1, 1)
        assert roots is None


def test_floats_precision():
    """Test calculation precision with floats."""
    result = quadratic.calculate_discriminant(1.5, 2.5, 1.0)
    expected = 2.5 ** 2 - 4 * 1.5 * 1.0
    assert abs(result - expected) < 1e-10


if __name__ == "__main__":
    import pytest
    pytest.main([__file__, "-v"])