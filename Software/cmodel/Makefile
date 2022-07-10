# 编译器配置
CC:=gcc
ARGS += "-g"

# 依赖库参数
LIBS = -lm -lpthread

# 源文件夹列表
DIR_SRC = src
DIR_OBJ = obj

# 判断目标目录是否存在
$(shell if [ ! -e $(DIR_OBJ) ];then mkdir -p $(DIR_OBJ); fi)

# 头文件目录列表
INC = -I$(DIR_SRC)

# obj中的.o文件统计
obj += ${patsubst %.c,$(DIR_OBJ)/%.o,${notdir ${wildcard $(DIR_SRC)/*.c}}}

# 文件夹编译及.o文件转储
%.o:../$(DIR_SRC)/%.c
	@$(CC) -Wall -c $< $(INC) $(ARGS) $(LIBS) -o $@

# 目标编译
target: $(obj)
	@$(CC) -Wall -o upscale $(obj) $(INC) $(ARGS) $(LIBS)

clean:
	@rm ./$(DIR_OBJ)/* upscale $(DIR_OBJ) -rf
