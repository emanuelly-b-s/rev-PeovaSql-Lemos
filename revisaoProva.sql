use master
go

if exists(select * from sys.databases where name = 'TESTE')
drop database TESTE
go

CREATE DATABASE TESTE
go

USE TESTE
go

CREATE TABLE Curso
(
	id INT IDENTITY (1,1) PRIMARY KEY,
	Nome VARCHAR(30),
	Valor MONEY DEFAULT 200
);
go


CREATE TABLE Professor
(
	id INT IDENTITY (1,1) PRIMARY KEY,
	Nome VARCHAR(30),
	CPF VARCHAR(12)
);
go


CREATE TABLE Turma
(
	id INT IDENTITY (1,1) PRIMARY KEY,
	id_Curso INT,
	foreign key (id_Curso) references Curso(id),
	Dt_inicio DATE,
	Dt_termino DATE,
	id_Professor INT,
	foreign key (id_Professor) references Professor(id),
);
go

CREATE TABLE Aluno
(
	id INT IDENTITY (1,1) PRIMARY KEY,
	Nome VARCHAR(30),
	Dt_Nasc DATE CHECK (Dt_Nasc > '01/01/1922'),
	CPF VARCHAR(12)
);
go

CREATE TABLE AlunoXTurma
(
	id INT IDENTITY (1,1) PRIMARY KEY,
	id_turma INT,
	foreign key (id_turma) references Turma(id),
	id_aluno INT,
	foreign key (id_aluno) references Aluno(id),
);
go




ALTER TABLE Aluno ADD Ativo BIT 
ALTER TABLE Professor ADD Ativo BIT 

select * from AlunoXTurma
select * from Professor
select * from Curso
select * from Turma
select * from Aluno


insert into Curso values ('Desenvolvimento de Sistemas', 578.9)
insert into Curso values ('Mecatronica', 321.9)
insert into Curso values ('Mecanica', 212.85)
insert into Curso values ('Robotica', 678.9)
insert into Curso(Nome) values ('Analise de dados')
insert into Curso(Nome) values ('Manufatura')


insert into Aluno values ('Maite','23/02/2004','10100251986',1)
insert into Aluno values ('Joao','20-08-2001','10100251987',0)
insert into Aluno values ('Manu','15-03-2004','10100251988',0)
insert into Aluno values ('Pedro','16-08-1998','10100251989',1)
insert into Aluno values ('Lucas','25-10-1996','10100251980',0)
insert into Aluno values ('Matheus','12-12-2012','10100251981',1)
insert into Aluno values ('Ricardo','01-01-1990','10100251982',0)
insert into Aluno values ('Pricila','01-01-1995','10100251975',1)
insert into Aluno values ('Japones','01-01-2013','10100251956',0)
insert into Aluno values ('Carequis','01-01-2000','10100251903',0)


insert into Professor values ('Trevisan', '10120340256', 1)
insert into Professor values ('Lemos', '10120340255', 1)
insert into Professor values ('Gustavo', '10120340254', 1)
insert into Professor values ('Josemar', '10120340253', 0)
insert into Professor values ('Vinicius', '10120340250', 0)
insert into Professor values ('Diego', '10120340259', 1)

insert into Turma values (3, '15-06-2018', '15-08-2020', 5)
insert into Turma values (5, '02-03-2023', '10-12-2024', 3)
insert into Turma values (2, '10-01-2022', '18-08-2023', 5)
insert into Turma values (1, '08-08-2022', '23-05-2024', 1)
insert into Turma values (6, '23-12-2021', '20-11-2022', 2)



insert into AlunoXTurma values (1, 1)
insert into AlunoXTurma values (1, 4)
insert into AlunoXTurma values (2, 5)
insert into AlunoXTurma values (2, 6)
insert into AlunoXTurma values (3, 10)
insert into AlunoXTurma values (4, 3)
insert into AlunoXTurma values (5, 7)
insert into AlunoXTurma values (4, 8)
insert into AlunoXTurma values (4, 1)
insert into AlunoXTurma values (5, 1)
insert into AlunoXTurma values (3, 1)

update Turma set Dt_termino = '03-12-2022' where id = 2

update Professor set Nome = 'Vinicius R' where Nome = 'Vinicius'

delete Professor from Professor p LEFT JOIN TURMA T ON T.id_Professor = P.id WHERE id_Curso IS NULL

--•	Crie uma view que faça um select que mostre os nomes dos alunos, o nome do curso que estão inscritos e o nome do professor responsável

CREATE VIEW EXIBIR AS 
SELECT A.NOME AS 'NOME ALUNO', C.NOME AS 'CURSO', P.NOME AS 'PROFESSOR' 
FROM Turma T join AlunoXTurma Al on t.id = Al.id_turma 
join Aluno A on A.id = Al.id 
join Curso C on T.id_Curso = C.id
join Professor P on T.id_Professor = p.id
select * from EXIBIR

--Crie uma view que faça um select mostrando o nome de todos os cursos que já iniciaram
--(data de inicio maior que a data atual) e que terminam antes do dia 01/06/2023
CREATE VIEW EXIBICURSO AS
SELECT C.Nome 
FROM Turma T JOIN Curso C ON T.id_Curso = C.id
WHERE T.Dt_inicio > CAST(getdate() as date) and T.Dt_termino < '2023-06-01'
SELECT * FROM EXIBICURSO

--crie uma view que faça um select mostrando o nome dos alunos que gastaram mais de 1.000,00 no ano atual
CREATE VIEW NOMEALUNO
AS
SELECT A.NOME FROM Turma T JOIN AlunoXTurma AL ON AL.id_turma = T.id 
JOIN Aluno A ON AL.id_aluno = A.id
JOIN Curso C ON C.id = T.id_Curso
GROUP BY A.NOME
    HAVING SUM(C.VALOR) >= 1000

SELECT * FROM NOMEALUNO


--Faça uma procedure que receba uma data e mostre os cursos que começaram antes dessa data e ainda não terminaram
CREATE OR ALTER PROCEDURE MOSTRACURSO @DATA DATE
AS
BEGIN
	SELECT C.NOME FROM Curso C JOIN TURMA T ON T.id_Curso = C.id
	WHERE T.Dt_inicio < @DATA AND T.Dt_termino > @DATA
END

EXEC MOSTRACURSO'15-03-2022'

/*Faça uma procedure que receba um cpf e um valor do tipo BIT. Se o valor do BIT for 1 mostre os cursos 
em que esse CPF está inscrito e que já terminaram, se o valor do BIT for 0, 
mostre os cursos em que esse CPF está inscrito e que ainda estão em andamento*/

CREATE OR ALTER PROC MCURSOATIIVO @CPF VARCHAR (20), @ATIVO BIT 
AS
	BEGIN
		IF @ATIVO = 1 
			SELECT A.CPF, A.NOME, C.NOME, T.Dt_inicio, T.Dt_termino 
			FROM Turma T JOIN AlunoXTurma AL ON T.id = AL.id_turma
			JOIN Aluno A ON A.id = AL.id_aluno
			JOIN Curso C ON T.id_Curso = C.id
			WHERE A.CPF = @CPF AND T.Dt_termino < CAST(getdate() as date)
		ELSE 
			SELECT A.CPF, A.NOME, C.NOME, T.Dt_inicio, T.Dt_termino 
			FROM Turma T JOIN AlunoXTurma AL ON T.id = AL.id_turma
			JOIN Aluno A ON A.id = AL.id_aluno
			JOIN Curso C ON T.id_Curso = C.id
			WHERE A.CPF = @CPF AND T.Dt_termino > CAST(getdate() as date)
	END

EXEC MCURSOATIIVO '10100251975', 0


/*Faça uma procedure que receba um CPF e retorne (por parâmetro de saída) todo o valor já gasto por este cpf*/
CREATE OR ALTER PROC VALORGASTO @CPF VARCHAR(20), @VALOR SMALLMONEY OUTPUT, @NOME VARCHAR(50) OUTPUT
AS
	BEGIN
		SELECT @VALOR = SUM(C.VALOR), @NOME = A.Nome FROM CURSO C JOIN Turma T ON T.id_Curso = C.id
		JOIN AlunoXTurma AL ON AL.id_turma = T.id 
		JOIN Aluno A ON AL.id_aluno = A.id
		WHERE A.CPF = @CPF
		GROUP BY A.Nome
	END

DECLARE @VALOR SMALLMONEY
DECLARE @NOME VARCHAR(50)

EXEC VALORGASTO '10100251975',
@VALOR = @VALOR OUTPUT,
@NOME = @NOME OUTPUT

SELECT @VALOR, @NOME


/*•	Crie uma trigger para a tabela aluno e uma para a tabela professor que não permita deletes e 
ao invés disso atualize a coluna ATIVO para 0 */
CREATE OR ALTER TRIGGER NOTDELETE 
ON ALUNO 
INSTEAD OF DELETE --INSTEAD OF faz com que o trigger seja executado no lugar da ação que o gerou. --DELETED contém as linhas excluídas.
AS
    BEGIN
        DECLARE @NOME_ALUNO VARCHAR(100)
        SELECT @NOME_ALUNO = NOME FROM DELETED
        UPDATE ALUNO
        SET Ativo = 0
        WHERE NOME = @NOME_ALUNO
    END

DELETE FROM Aluno WHERE Nome = 'Pedro'
SELECT * FROM Aluno

--•	Crie uma tabela chamada HISTORICO_INSERCAO com as colunas: Id Função Data
CREATE TABLE HIST_INSERCAO(
ID_P INT,
FUNCAO VARCHAR(50),
DATA_F DATE
)

--Crie uma trigger para as tabelas Aluno e Professor, para que quando forem inseridos dados nestas tabelas, faça também um insert 
--na tabela HISTORICO_INSERCAO, inserindo nesta o Id da pessoas que acabou de ser inerida, 
--a função (se o insert veio da tabela aluno insira “aluno” e se veio da tabela professor insira “professor”) e a data atual.
CREATE OR ALTER TRIGGER HIST
ON ALUNO
AFTER INSERT 
AS
	BEGIN
		DECLARE @ID INT
		DECLARE @FUNCAO VARCHAR (20)
		DECLARE @DATAf DATE

		SELECT @ID = id FROM inserted
	
		INSERT INTO HIST_INSERCAO VALUES (@ID, 'ALUNO', GETDATE())
	END

INSERT INTO Aluno VALUES ('SEILA', '28-02-2000', '10100251946', 1)

SELECT * FROM HIST_INSERCAO