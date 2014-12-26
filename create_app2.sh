#!/bin/bash
if [ -n "$1" ]; then
    PROJECT_NAME=$1
else
    PROJECT_NAME="Exemplar"
fi
mkdir $PROJECT_NAME
cd $PROJECT_NAME
rebar create-app appid=$PROJECT_NAME
mkdir rel
cd rel
rebar create-node nodeid=$PROJECT_NAME
#search="s/{app,\,\s\[{incl_cond,\sinclude}\]}/"
conf1="{app, hipe, [{incl_cond, exclude}]},"
conf2="       {app, $PROJECT_NAME, [{mod_cond, app}, {incl_cond, include}, {lib_dir, \"..\"}]}"
sed -e "s/{app.*\,$//g" reltool.config > new.config
rm reltool.config
mv new.config reltool.config
sed -e "s/{app.*/$conf1\n$conf2/g" reltool.config > new.config
rm reltool.config
mv new.config reltool.config
conf3="{erts, [{mod_cond, derived}, {app_file, strip}]}, {app_file, strip},"
#cong4="{app_file, strip},"
sed -e "s/{erts.*/$conf3/g" reltool.config > new.config
rm reltool.config
mv new.config reltool.config

#{erts,
cd ..
echo "{sub_dirs, [\"rel\"]}.">>rebar.config
echo "{deps, [" >>rebar.config
echo "	{sync,        \".*\", {git, \"git://github.com/rustyio/sync.git\", \"master\"}}">>rebar.config
echo "]}.">>rebar.config
echo "# Feel free to use, reuse and abuse the code in this file.">>Makefile
echo "all: app">>Makefile
echo "app: get-deps">>Makefile
echo "	@rebar compile">>Makefile
echo "get-deps:">>Makefile
echo "	@rebar get-deps">>Makefile
echo "clean:">>Makefile
echo "	@rebar clean">>Makefile
echo "	rm -f erl_crash.dump">>Makefile
echo "dist-clean: clean">>Makefile
echo "run:">>Makefile
echo "#ERL_LIBS=deps erl -noinput -pa ebin -boot start_sasl -s ${PROJECT_NAME}_app > log/sasl.log">>Makefile
echo "	ERL_LIBS=deps erl -pa ebin -boot start_sasl -s ${PROJECT_NAME}_app">>Makefile
echo ".PHONY: app">>Makefile

cd ./src
cat ${PROJECT_NAME}_app.erl | sed '5a\-export([start/0]).'>ftest_app.erl_tmp
cat ./ftest_app.erl_tmp | sed "11a\start()->\n  ok=application:start(${PROJECT_NAME}).\n">ftest_app.erl_tmp2
rm ./ftest_app.erl_tmp
rm ./${PROJECT_NAME}_app.erl
mv ftest_app.erl_tmp2 ${PROJECT_NAME}_app.erl
echo "OK create"

