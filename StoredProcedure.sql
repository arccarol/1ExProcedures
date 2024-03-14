USE master
DROP DATABASE academia 

CREATE DATABASE academia;
GO
USE academia

CREATE TABLE Aluno (
    codigo_aluno INT IDENTITY(1,1),
    nome VARCHAR(100)
	PRIMARY KEY(codigo_aluno)
)
GO
CREATE TABLE Atividade (
    codigo INT,
    descricao VARCHAR(100),
    IMC FLOAT
	PRIMARY KEY(codigo)
)

INSERT INTO Atividade (codigo, descricao, IMC) VALUES
(1, 'Corrida + Step', 18.5),
(2, 'Biceps + Costas + Pernas', 24.9),
(3, 'Esteira + Biceps + Costas + Pernas', 29.9),
(4, 'Bicicleta + Biceps + Costas + Pernas', 34.9),
(5, 'Esteira + Bicicleta', 39.9)

CREATE TABLE Atividadesaluno (
    codigo_aluno INT,
    altura FLOAT,
    peso FLOAT,
    IMC FLOAT,
    Atividade INT,
    FOREIGN KEY (codigo_aluno) REFERENCES Aluno(codigo_aluno),
    FOREIGN KEY (Atividade) REFERENCES Atividade(codigo)
)

DROP PROCEDURE sp_alunoatividades

CREATE PROCEDURE sp_alunoatividades
    @op CHAR(1),
    @codigo_aluno_param INT = NULL,
    @nome_param VARCHAR(100) = NULL,
    @altura_param FLOAT = NULL,
    @peso_param FLOAT = NULL,
    @saida VARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @imc_calculado FLOAT;
    DECLARE @atividade_selecionada INT;

    SET @imc_calculado = @peso_param / POWER(@altura_param, 2);

    SELECT TOP 1 @atividade_selecionada = Codigo
    FROM Atividade
    WHERE IMC > @imc_calculado
    ORDER BY IMC ASC;
 
    IF @imc_calculado > 40
        SET @atividade_selecionada = 5;

    IF (@op = 'I')
    BEGIN

        INSERT INTO Aluno (Nome) VALUES (@nome_param);

        SET @codigo_aluno_param = SCOPE_IDENTITY(); --olha o ultimo codigo cadastrado

        INSERT INTO Atividadesaluno (Codigo_aluno, Altura, Peso, IMC, Atividade)
        VALUES (@codigo_aluno_param, @altura_param, @peso_param, @imc_calculado, @atividade_selecionada);

        SET @saida = 'Novo aluno e atividade inseridos com sucesso.';
    END
    ELSE IF (@op = 'U')
    BEGIN
    
        IF EXISTS (SELECT 1 FROM Aluno WHERE Codigo_aluno = @codigo_aluno_param)
        BEGIN
       
            UPDATE Atividadesaluno
            SET Altura = @altura_param,
                Peso = @peso_param,
                IMC = @imc_calculado,
                Atividade = @atividade_selecionada
            WHERE Codigo_aluno = @codigo_aluno_param;

            SET @saida = 'Dados do aluno e atividade atualizados com sucesso.';
        END
        ELSE
        BEGIN
            SET @saida = 'Código de aluno inválido.';
        END
    END
END;

--caso o codigo do aluno for nulo
DECLARE @saida VARCHAR(100);
EXEC sp_alunoatividades 
    @op = 'I',
    @nome_param = 'Carol',
    @altura_param = 1.64,
    @peso_param = 50,
    @saida = @saida OUTPUT;

PRINT @saida;

--para o nome nulo atualizando
DECLARE @saida VARCHAR(100);
EXEC sp_alunoatividades 
    @op = 'U',
    @codigo_aluno_param = 4, 
    @altura_param = 1.80,   
    @peso_param = 75,
    @saida = @saida OUTPUT;

PRINT @saida;

SELECT * from Aluno
SELECT * from Atividadesaluno




