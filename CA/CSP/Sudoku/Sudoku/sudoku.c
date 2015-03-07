//#define DEBUG
#define SEED 1234567890
#define MAXTRY 50
#define MAXSTEP 10000

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <time.h>

//data
static int _sudoku[9][9] = { 0 };
static int _kickoff[9][9] = { 0 };
static int _candidateCount[9][9] = { 0 };
static int _candidate[9][9][9] = { 0 };

//solver facade
typedef int(*solver)();
typedef int swopper(int sudoku[][9], int *row1, int *column1, int *row2, int *column2);
static int backtrackSAT();
static int urwalkSAT();
static int greedySAT();
static int annealingSAT();
static solver psolver = &annealingSAT;

//helper
static void init(int sudoku[][9]);
static void displayResult(int solved, char* which, int result[][9]);
static void debugRun();


//main
int main(int argc, char *argv[])
{
	srand(SEED);
	
#ifdef DEBUG
	debugRun();
	return;
#endif

	if (argc < 2)
	{
		printf("Usage: \n\tsudoku <sudoku-input-file.txt>\n");
		return 0;
	}
	if (readInput(argv[1]) != 1)
	{
		return 0;
	}
	if (isValidTest(_sudoku) == 0)
	{
		printf("Invalid test case.\n");
		return 0;
	}

	init(_sudoku);
	int solved = isSolved(_sudoku);
	if (solved == 0)
	{
		solved = psolver();
	}

	displayResult(solved, argv[1], _sudoku);
}

int readInput(char* path)
{
	char line[100];
	FILE *file;
	file = fopen(path, "r");
	if (file == NULL)
	{
		printf("Error opening file\n");
		return 0;
	}

	int i, row = 0, column;
	while (row < 9 && fgets(line, 100, file) != NULL)
	{
		i = 0;
		column = 0;
		while (line[i] == ' ')
			i++;
		if (line[i] == '#')		
			continue;
				
		while (column < 9 && line[i] != '\0')
		{
			if (isdigit(line[i]))
			{
				_kickoff[row][column] = line[i] - '0';
				column++;
			}	

			i++;
		}

		row++;
	}
		
	fclose(file);
	return 1;	
}

void debugRun()
{
	int tests[6][9][9] =
	{
		{
			{ 5, 3, 0, 0, 7, 0, 0, 0, 0 },
			{ 6, 0, 0, 1, 9, 5, 0, 0, 0 },
			{ 0, 9, 8, 0, 0, 0, 0, 0, 0 },
			{ 8, 0, 0, 0, 6, 0, 0, 0, 3 },
			{ 4, 0, 0, 8, 0, 3, 0, 0, 1 },
			{ 7, 0, 0, 0, 2, 0, 0, 0, 6 },
			{ 0, 6, 0, 0, 0, 0, 2, 8, 0 },
			{ 0, 0, 0, 4, 1, 9, 0, 0, 5 },
			{ 0, 0, 0, 0, 8, 0, 0, 7, 9 },
		},
		{
			{ 0, 0, 0, 8, 9, 6, 0, 0, 0 },
			{ 0, 7, 5, 0, 0, 0, 1, 0, 0 },
			{ 3, 0, 0, 0, 0, 0, 4, 0, 0 },
			{ 6, 0, 0, 1, 0, 0, 0, 0, 0 },
			{ 0, 2, 7, 0, 0, 0, 3, 1, 0 },
			{ 0, 0, 0, 0, 0, 5, 0, 0, 4 },
			{ 0, 0, 6, 0, 0, 0, 0, 0, 8 },
			{ 0, 0, 4, 0, 0, 0, 9, 7, 0 },
			{ 0, 0, 0, 2, 6, 3, 0, 0, 0 },
		},
		{
			{ 7, 9, 0, 0, 0, 0, 3, 0, 0 },
			{ 0, 0, 0, 0, 0, 6, 9, 0, 0 },
			{ 8, 0, 0, 0, 3, 0, 0, 7, 6 },
			{ 0, 0, 0, 0, 0, 5, 0, 0, 2 },
			{ 0, 0, 5, 4, 1, 8, 7, 0, 0 },
			{ 4, 0, 0, 7, 0, 0, 0, 0, 0 },
			{ 6, 1, 0, 0, 9, 0, 0, 0, 8 },
			{ 0, 0, 2, 3, 0, 0, 0, 0, 0 },
			{ 0, 0, 9, 0, 0, 0, 0, 5, 4 },
		},
		{
			{ 0, 0, 2, 8, 0, 7, 9, 0, 0 },
			{ 0, 4, 0, 0, 0, 0, 0, 1, 0 },
			{ 8, 0, 0, 0, 1, 0, 0, 0, 7 },
			{ 7, 0, 0, 1, 0, 5, 0, 0, 9 },
			{ 0, 0, 9, 0, 0, 0, 6, 0, 0 },
			{ 2, 0, 0, 3, 0, 6, 0, 0, 8 },
			{ 1, 0, 0, 0, 8, 0, 0, 0, 6 },
			{ 0, 6, 0, 0, 0, 0, 0, 4, 0 },
			{ 0, 0, 4, 2, 0, 9, 1, 0, 0 },
		},
		{
			{ 0, 3, 5, 1, 0, 6, 0, 0, 9 },
			{ 0, 6, 9, 0, 0, 3, 7, 8, 0 },
			{ 0, 0, 1, 0, 2, 9, 3, 5, 0 },
			{ 0, 9, 0, 7, 5, 0, 0, 3, 4 },
			{ 5, 2, 8, 0, 9, 0, 0, 6, 0 },
			{ 7, 0, 0, 0, 1, 8, 0, 9, 2 },
			{ 3, 0, 0, 2, 0, 7, 9, 0, 5 },
			{ 9, 5, 2, 4, 0, 0, 6, 0, 0 },
			{ 6, 0, 0, 9, 3, 0, 2, 0, 8 },
		},
		{
			{ 0, 0, 8, 3, 4, 2, 9, 0, 0 },
			{ 0, 0, 9, 0, 0, 0, 7, 0, 0 },
			{ 4, 0, 0, 0, 0, 0, 0, 0, 3 },
			{ 0, 0, 6, 4, 7, 3, 2, 0, 0 },
			{ 0, 3, 0, 0, 0, 0, 0, 1, 0 },
			{ 0, 0, 2, 8, 5, 1, 6, 0, 0 },
			{ 7, 0, 0, 0, 0, 0, 0, 0, 8 },
			{ 0, 0, 4, 0, 0, 0, 1, 0, 0 },
			{ 0, 0, 3, 6, 9, 7, 5, 0, 0 },
		}
	};

	int i;		
	for (i = 0; i < 6; i++)
	{
		memcpy(_sudoku, tests[i], sizeof(_sudoku));		
		if (isValidTest(_sudoku) == 0)
		{
			printf("Invalid test case.\n");
			continue;
		}

		init(_sudoku);

		int solved = isSolved(_sudoku);
		if (solved == 0)
		{
			solved = psolver();
		}
		
		displayResult(solved, "###debug", _sudoku);
		
		memset(_sudoku, 0, sizeof(_sudoku));
		memset(_kickoff, 0, sizeof(_kickoff));
		memset(_candidateCount, 0, sizeof(_candidateCount));
		memset(_candidate, 0, sizeof(_candidate));
	}
}


/////////////////////////////////////////////////
///Implementations - BEGIN

int fitsRow(int row, int num, int sudoku[][9])
{
	int column;
	for (column = 0; column < 9; column++)
		if (sudoku[row][column] == num)
			return 0;
	return 1;
}

int fitsColumn(int column, int num, int sudoku[][9])
{
	int row;
	for (row = 0; row < 9; row++)
		if (sudoku[row][column] == num)
			return 0;
	return 1;
}

int fitsZone(int row, int column, int num, int sudoku[][9])
{
	row = (row / 3) * 3;
	column = (column / 3) * 3;
	int r, c;
	for (r = 0; r < 3; r++)
		for (c = 0; c < 3; c++)
			if (sudoku[row + r][column + c] == num)
				return 0;
	return 1;
}

int isValidTest(int sudoku[][9])
{
	int i, j, k;
	for (i = 0; i < 9; i++)
	{
		for (j = 0; j < 9; j++)
		{
			if (sudoku[i][j] != 0) {
				//remaining row				
				for (k = j + 1; k < 9; k++)
				{
					if (sudoku[i][j] == sudoku[i][k])
					{
						printf("Duplicate value {%d}: [%d, %d], [%d, %d]\n", sudoku[i][j], i + 1, j + 1, i + 1, k + 1);
						return 0;
					}
				}
				//remaining column
				for (k = i + 1; k < 9; k++)
				{
					if (sudoku[i][j] == sudoku[k][j])
					{
						printf("Duplicate value {%d}: [%d, %d], [%d, %d]\n", sudoku[i][j], i + 1, j + 1, k + 1, j + 1);
						return 0;
					}
				}
				//remaining zone
				int zi = (i / 3) * 3;
				int zj = (j / 3) * 3;
				int r = i % 3, c = j % 3 + 1;
				if (c % 3 == 0)
				{
					r++;
					c = 0;
				}
				for (; r < 3; r++)
				{
					for (; c < 3; c++)
					{
						if (sudoku[i][j] == sudoku[zi + r][zj + c])
						{
							printf("Duplicate value {%d}: [%d, %d], [%d, %d]\n", sudoku[i][j], i + 1, j + 1, zi + r + 1, zj + c + 1);
							return 0;
						}
					}
					c = 0;
				}
			}
		}
	}
}

void updateCandidate(int row, int column, int sudoku[][9])
{
	int i, n = 0;
	for (i = 1; i <= 9; i++)
	{
		if ((fitsRow(row, i, sudoku) == 1) && (fitsColumn(column, i, sudoku) == 1) && (fitsZone(row, column, i, sudoku) == 1))
		{
			_candidate[row][column][n] = i;
			n++;
		}
	}

	_candidateCount[row][column] = n;
}

void displayResult(int solved, char* which, int result[][9])
{
	if (solved == 1)
	{
		printf("# %s: satisfiable solution\n", which);
		int row, column;
		for (row = 0; row < 9; row++)
		{
			for (column = 0; column < 9; column++)
				printf("%d ", result[row][column]);
			printf("\n");
		}
	}
	else
	{
		printf("# %s: unsolved\n", which);
	}
}

void solveHeuristically(int sudoku[][9])
{
	int any, row, column;
	do
	{
		any = 0;
		for (row = 0; row < 9; row++)
		{
			for (column = 0; column < 9; column++)
			{
				if (sudoku[row][column] > 0)
				{
					_candidateCount[row][column] = 0;					
				}
				else
				{
					updateCandidate(row, column, sudoku);
					if (_candidateCount[row][column] == 1)
					{
						sudoku[row][column] = _candidate[row][column][0];	
						_candidateCount[row][column] = 0;
						any++;
					}					
				}
			}
		}
	} while (any > 0);
}

void init(int sudoku[][9])
{	
	solveHeuristically(sudoku);
	memcpy(_kickoff, sudoku, sizeof(_kickoff));
}

int solve(solver psolver, int sudoku[][9])
{
#ifdef DEBUG
	int start = time(NULL);
#endif
	int solved = psolver(sudoku);
#ifdef DEBUG
	int end = time(NULL);
	printf("######## solving duration(s) - %d\n\n", end - start);
#endif
	return solved;
}

int isSolved(int sudoku[][9])
{
	int count[10] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

	int row, column, i, j, sum;
	for (row = 0; row < 9; row++)
	{
		for (column = 0; column < 9; column++)
		{
			count[sudoku[row][column]]++;
		}
	}

	for (i = 0; i < 10; i++)
	{
		if (i == 0)
		{
			if (count[i] > 0)
				return 0;
		}
		else if (count[i] != 9)
			return 0;
	}
	
	for (row = 0; row < 9; row++)
	{
		sum = 0;
		for (column = 0; column < 9; column++)
			sum += sudoku[row][column];
		if (sum != 45)
			return 0;
	}

	for (column = 0; column < 9; column++)	
	{
		sum = 0;
		for (row = 0; row < 9; row++)
			sum += sudoku[row][column];
		if (sum != 45)
			return 0;
	}

	for (row = 0; row < 3; row++)
	{		
		for (column = 0; column < 3; column++)
		{
			sum = 0;
			for (i = 0; i < 3; i++)
			{
				for (j = 0; j  < 3; j ++)
				{
					sum += sudoku[row * 3 + i][column * 3 + j];
				}
			}
			if (sum != 45)
				return 0;
		}
	}

	return 1;
}

int getViolations(int sudoku[][9])
{
	int value[10] = { 0 }, violation = 0, v;
	int i, j;
	for (i = 0; i < 9; i++)
	{		
		for (j = 1; j < 10; j++) 
			value[j] = j;

		for (j = 0; j < 9; j++)
		{
			v = sudoku[i][j];
			if (value[v] > 0)
			{
				value[v] = 0;
				violation--;
			}
		}
	}

	for (i = 0; i < 9; i++)
	{
		for (j = 1; j < 10; j++)
			value[j] = j;

		for (j = 0; j < 9; j++)
		{
			v = sudoku[j][i];
			if (value[v] > 0)
			{
				value[v] = 0;
				violation--;
			}
		}
	}

	return violation;
}

int deltaViolations(int sudoku[][9], int row1, int column1, int row2, int column2)
{
	if (row1 == row2 && column1 == column2)
		return 0;

	int before, after, v1, v2;
	v1 = sudoku[row1][column1];
	v2 = sudoku[row2][column2];

	before = getViolations(sudoku);
	
	sudoku[row1][column1] = v2;
	sudoku[row2][column2] = v1;

	after = getViolations(sudoku);

	sudoku[row1][column1] = v1;
	sudoku[row2][column2] = v2;

	return after - before;
}

///Solver - BEGIN

int fillOneZone(int sudoku[][9], int zoneRow, int zoneColumn, int value[], int r, int c)
{
	if (c == 3)
	{
		r++;
		c == 0;
	}
	if (r == 3)
		return 1;

	int v, v0, row, column;
	row = zoneRow * 3 + r;
	column = zoneColumn * 3 + c;
	v = sudoku[row][column];
	if (v > 0)
	{
		value[v] = 0;
		return fillOneZone(sudoku, zoneRow, zoneColumn, value, r, c + 1);
	}

	int i, n, offset, found;
	n = _candidateCount[row][column];
	offset = rand() % n;
	found = 0;
	for (i = 0; i < n; i++)
	{
		v = _candidate[row][column][(i + offset) % n];
		if (value[v] > 0)
		{
			v0 = value[v];
			sudoku[row][column] = v;
			value[v] = 0;
			if (fillOneZone(sudoku, zoneRow, zoneColumn, value, r, c + 1) == 1)
				return 1;
			else
				value[v] = v0;
		}
	}

	sudoku[row][column] = 0;
	return 0;
}

int validateZone(int sudoku[][9], int zoneRow, int zoneColumn)
{
	int value[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
	int r, c, v, n = 0;
	for (r = 0; r < 3; r++)
	{
		for (c = 0; c < 3; c++)
		{
			v = sudoku[zoneRow * 3 + r][zoneColumn * 3 + c];
			if (value[v] == 0)
				return 0;
			else
				value[v] = 0;
		}
	}

	return 1;
}

void fillZone(int sudoku[][9])
{
	int zoneRow, zoneColumn, cn, found;
	int value[10];
	for (zoneRow = 0; zoneRow < 3; zoneRow++)
	{
		for (zoneColumn = 0; zoneColumn < 3; zoneColumn++)
		{			
			int row, column, r, c, v, i;
			int n, offset, found;
			//init value
			for (i = 0; i < 10; i++)
				value[i] = i;

			for (r = 0; r < 3; r++)
			{
				row = zoneRow * 3 + r;
				for (c = 0; c < 3; c++)
				{
					column = zoneColumn * 3 + c;
					v = _kickoff[row][column];
					if (v > 0)
						value[v] = 0;					
				}
			}

			//fill
			for (r = 0; r < 3; r++)
			{
				row = zoneRow * 3 + r;
				for (c = 0; c < 3; c++)
				{
					column = zoneColumn * 3 + c;
					v = sudoku[row][column];
					if (v > 0)
					{
						value[v] = 0;
					}
					else
					{
						found = 0;
						cn = _candidateCount[row][column];
						offset = rand() % cn;
						for (i = 0; i < cn; i++)
						{
							v = value[_candidate[row][column][(i + offset) % cn]];
							if (v > 0)
							{
								sudoku[row][column] = v;
								value[v] = 0;
								found = 1;
								break;
							}
						}
						if (found == 1)
							continue;
						
						//
						offset = rand() % 9;
						for (i = 1; i < 10; i++)
						{
							v = value[(i + offset) % 9 + 1];
							if (v > 0)
							{
								sudoku[row][column] = v;
								value[v] = 0;
								break;
							}
						}
					}
				}
			}

#ifdef DEBUG
			if (validateZone(sudoku, zoneRow, zoneColumn) == 0)
				printf("invalid zone\n");
#endif
		}
	}	
}

int randomSwop(int sudoku[][9], int *row1, int *column1, int *row2, int *column2)
{
	int num, num1, num2;
	int zrow, zcolumn;
	int r, c, row, column;
	int offsetr1, offsetc1, offsetr2, offsetc2;
	int found1 = 0, found2 = 0;
		
	while (1)
	{
		//zone
NEXTZONE:
		num = rand() % 9;
		zrow = num / 3;
		zcolumn = num % 3;

		//cell1 offset
		num1 = rand() % 9;
		offsetr1 = num1 / 3;
		offsetc1 = num1 % 3;

		for (r = 0; r < 3; r++)
		{
			row = zrow * 3 + (r + offsetr1) % 3;
			for (c = 0; c < 3; c++)
			{				
				column = zcolumn * 3 + (c + offsetc1) % 3;
				if (_kickoff[row][column] == 0)
				{
					found1 = 1;
					*row1 = row;
					*column1 = column;

					//cell2 offset
					num2 = rand() % 9;
					offsetr2 = num2 / 3;
					offsetc2 = num2 % 3;

					for (r = 0; r < 3; r++)
					{
						row = zrow * 3 + (r + offsetr2) % 3;
						for (c = 0; c < 3; c++)
						{							
							column = zcolumn * 3 + (c + offsetc2) % 3;
							if ((row != row1 || column != column1) && _kickoff[row][column] == 0)
							{
								found2 = 1;
								*row2 = row;
								*column2 = column;
								return 1;
							}
						}						
					}

					goto NEXTZONE;
				}
			}
		}
	}

	return 0;
}

void getCoordinate(int i, int *row, int *column)
{
	*row = i / 9;
	*column = i % 9;
}

int greedySwop(int sudoku[][9], int *row1, int *column1, int *row2, int *column2)
{
	int delta, min = 0;
	int r1, c1, r2, c2;
	int i, j, row, column;

	for (i = 0; i < 81; i++)
	{
		getCoordinate(i, &r1, &c1);
		if (_kickoff[r1][c1] == 0)
		{			
			for (j = i + 1; j < 81; j++)
			{
				if (i / 27 == j / 27 && (i % 9) / 3 == (j % 9) / 3)
				{
					getCoordinate(j, &r2, &c2);
					if (_kickoff[r2][c2] == 0)
					{					
						delta = deltaViolations(sudoku, r1, c1, r2, c2);						
						if (delta < min || delta == min && rand() % 100 > 50)							
						{
							min = delta;
							*row1 = r1;
							*column1 = c1;
							*row2 = r2;
							*column2 = c2;
						}
					}
				}
			}
		}
	}

	return min;	
}

void flipZone(int sudoku[][9], swopper swop)
{
	int row1, column1, row2, column2, t;
	int swopped = swop(sudoku, &row1, &column1, &row2, &column2);
	if (swopped > 0)
	{
		t = sudoku[row1][column1];
		sudoku[row1][column1] = sudoku[row2][column2];
		sudoku[row2][column2] = t;
	}
}

int solveDFInternal(int sudoku[][9], int row, int column)
{
	if (column > 8)
	{
		row++;
		column = 0;
	}

	if (row > 8)
		return 1;
	
	if (sudoku[row][column] != 0)
	{
		return solveDFInternal(sudoku, row, column + 1);
	}
	else
	{
		int i;
		for (i = 1; i <= 9; i++)
		{
			if ((fitsRow(row, i, sudoku) == 1) && (fitsColumn(column, i, sudoku) == 1) && (fitsZone(row, column, i, sudoku) == 1))
			{
				sudoku[row][column] = i;
				if (solveDFInternal(sudoku, row, column + 1) == 1)
					return 1;
			}
		}
		//prune
		sudoku[row][column] = 0;
		return 0;
	}
}

int backtrackSAT()
{
	return solveDFInternal(_sudoku, 0, 0);
}

int urwalkSAT()
{		
	int i, r, row, column;
	fillZone(_sudoku);
	for (i = 0; i < MAXSTEP; i++)
	{
		flipZone(_sudoku, randomSwop);		
		if (isSolved(_sudoku) == 1)
			return 1;
	}

	return 0;
}

int greedySAT()
{
	int restart, i, r, row, column, violations;
	for (restart = 0; restart < MAXTRY; restart++)
	{
		memcpy(_sudoku, _kickoff, sizeof(_sudoku));
		fillZone(_sudoku);
		for (i = 0; i < MAXSTEP; i++)
		{
			flipZone(_sudoku, greedySwop);
			if (isSolved(_sudoku) == 1)
				return 1;
		}
	}			
	
	return 0;
}

int annealingSAT()
{
	int restart, i, r, row, column, violations;
	double proba;
	double alpha = 0.999;
	double temperature = 400.0;
	double epsilon = 0.001;
	double delta;

	int row1, column1, row2, column2, t;		
	for (restart = 0; restart < MAXTRY; restart++)
	{
		memcpy(_sudoku, _kickoff, sizeof(_sudoku));
		fillZone(_sudoku);
			
		temperature = 400.0;
		while (temperature > epsilon)
		{				
			randomSwop(_sudoku, &row1, &column1, &row2, &column2);			
			delta = deltaViolations(_sudoku, row1, column1, row2, column2);								
			if (delta < 0 || (rand() % 1000) / 1000.0 < exp(-delta / temperature))
			//if ((rand() % 1000) / 1000.0 < exp(-delta / temperature))
			{
				t = _sudoku[row1][column1];
				_sudoku[row1][column1] = _sudoku[row2][column2];
				_sudoku[row2][column2] = t;
			}
				
			temperature *= alpha;

			if (isSolved(_sudoku) == 1)
				return 1;
		}					
	}

	return 0;
}
///Solver - END

///Implementations - END
