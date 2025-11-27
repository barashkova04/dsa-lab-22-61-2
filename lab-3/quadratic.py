"""
Module for solving quadratic equations.
"""


def calculate_discriminant(a, b, c):
    """
    Calculate discriminant for quadratic equation ax² + bx + c = 0.
    
    Args:
        a: Coefficient a
        b: Coefficient b  
        c: Coefficient c
        
    Returns:
        Discriminant value D = b² - 4ac
    """
    return b ** 2 - 4 * a * c


def solve_quadratic(a, b, c):
    """
    Solve quadratic equation and return roots.
    
    Args:
        a: Coefficient a
        b: Coefficient b
        c: Coefficient c
        
    Returns:
        Roots of equation or None if no real roots
    """
    discriminant = calculate_discriminant(a, b, c)
    
    if discriminant < 0:
        return None
    elif discriminant == 0:
        root = -b / (2 * a)
        return (root,)
    else:
        root1 = (-b + discriminant ** 0.5) / (2 * a)
        root2 = (-b - discriminant ** 0.5) / (2 * a)
        return (root1, root2)


if __name__ == "__main__":
    # Example usage
    try:
        a_val = float(input("Enter coefficient a: "))
        b_val = float(input("Enter coefficient b: "))
        c_val = float(input("Enter coefficient c: "))
        
        disc = calculate_discriminant(a_val, b_val, c_val)
        roots = solve_quadratic(a_val, b_val, c_val)
        
        print(f"Discriminant: {disc}")
        
        if roots is None:
            print("No real roots")
        elif len(roots) == 1:
            print(f"One root: x = {roots[0]}")
        else:
            print(f"Two roots: x1 = {roots[0]}, x2 = {roots[1]}")
            
    except ValueError:
        print("Error: please enter numeric values for coefficients")