//--- 277P

class TetrisShape {
   protected:
    int type;
    int xpos;
    int ypos;
    int xsize;
    int ysize;
    int prevTurn;
    int turn;
    int rightBorder;

   public:
    void tetrisShape();
    void setRightBorder(int border) { rightBorder = border; }
    void setYPos(int pYpos) { ypos = pYpos; }
    void setXPos(int pXpos) { xpos = pXpos; }
    int getYPos() { return ypos; }
    int getXPos() { return xpos; }
    int getYSize() { return ysize; }
    int getXSize() { return xsize; }
    int getType() { return type; }
    void moveLeft() { xpos -= SHAPE_SIZE; }
    void moveRight() { xpos += SHAPE_SIZE; }
    void rotate() {
        prevTurn = turn;
        if (++m_turn > 3) m_turn = 0;
    }
    virtual void draw() { return; }
    virtual bool checkDown(int& padArray[]);
    virtual bool checkLeft(int& sideRow[]);
    virtual bool checkRight(int& sideRow[]);
}

class TetrisShape1 : public TetrisShape {
   public:
    virtual void draw() {
        string name;
        if (turn == 0 || turn == 2) {
            for (int i = 0; i < 4; i++) {
                name = SHAPE_NAME + (string)i;
                ObjectSetInteger(0, name, OBJPROP_XDISTANCE,
                                 xpos + i * SHAPE_SIZE);
                ObjectSetInteger(0, name, OBJPROP_YDISTANCE, ypos);
            }
        } else {
            for (int i = 0; i < 4; i++) {
                name = SHAPE_NAME + (string)i;
                ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xpos);
                ObjectSetInteger(0, name, OBJPROP_YDISTANCE,
                                 ypos + i * SHAPE_SIZE);
            }
        }
    }
}

class TetrisShape6 : public TetrisShape {
   public:
    virtual void draw() {
        string name;
        for (int i = 0; i < 2; i++) {
            name = SHAPE_NAME + (string)i;
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, xpos + i * SHAPE_SIZE);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, ypos);
        }
        for (int i = 2; i < 4; i++) {
            name = SHAPE_NAME + (string)i;
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE,
                             xpos + (i - 2) * SHAPE_SIZE);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, ypos + SHAPE_SIZE);
        }
    }
}

void TetrisField::NewShape() {
    int shape = rand() % 7;
    switch (shape) {
        case 0:
            shape = new TetrisShape1;
            braek;
        case 1:
            shape = new TetrisShape6;
            break;
    }

	shape.draw();
}