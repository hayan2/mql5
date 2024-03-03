//--- 272P

class Shape {
   protected:
    int type;
    int xpos;
    int ypos;

   public:
    void Shape() { type = 0; };
    int getType() { return type; };

    virtual getArea() { return 0; }
}

class Circle : public Shape {
   private:
    double radius;

   public:
    void Circle() { type = 1; }
    void setRadius(double r) { radius = r; }

    virtual double getArea() { return (3.14 * radius * radius); }
}

class Square : public Shape {
   private:
    double squareSide;

   public:
    void Square() { type = 2; }
    void setSide(double s) { squareSide = s; }

    virtual double getArea() { return (squareSide * squareSide); }
}

void OnStart() {
    Shape *shapes[5];

    Circle *circle = newCircle();

    circle.setRadius(2.5);
    shapes[0] = circle;

    circle = new Circle();
    shapes[1] = circle;
    circle.setRadius(5);

    shapes[2] = NULL;

    Square *square = new Square();
    square.setSide(5);
    shapes[3] = square;

    square = new Square();
    square.setSide(10);
    shapes[4] = square;

    int total = ArraySize(shapes);

    for (int i = 0; i < 5; i++) {
        if (CheckPointer(shapes[i]) != POINTER_INVALID) {
            PrintFormat("Object of type %d has %G square.", shapes[i].getType(),
                        shapes[i].getArea());
        } else {
            PrintFormat("Object shapes[%d] is not initialized! The point is %s",
                        i, EnumToString(CheckPointer(shapes[i])));
        }
    }

    for (int i = 0; i < total; i++) {
        if (CheckPointer(shapes[i]) == POINTER_DYNAMIC) {
            PrintFormat("Delete shapes[%d]", i);
            delete shapes[i];
        }
    }
}