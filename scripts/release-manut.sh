#!/bin/bash
set -e	

# CALCULA AS VERSOES DE ACORDO COM A VERSAO DA MASTER
git checkout master
git pull origin master -q
CURRENT_MANUT_VERSION=`mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`
NEW_VERSION=${CURRENT_MANUT_VERSION%-*}
NEW_MANUT_VERSION=${NEW_VERSION%.*}.$((${NEW_VERSION##*.} + 1))-SNAPSHOT

# PEDE CONFIRMACAO DAS VERSOES
echo [RELEASE] --------------------------------------------------
echo "[RELEASE] Versao atual de manutencao.......$CURRENT_MANUT_VERSION"
echo "[RELEASE] Release a ser gerado.............$NEW_VERSION"
echo "[RELEASE] Nova versao de manutencao........$NEW_MANUT_VERSION"
echo [RELEASE] --------------------------------------------------

if [ "$1" != "-y" ]
then
	read -p "[RELEASE] Confirma o release? " -n 1 -r
	if [[ ! $REPLY =~ ^[Ss]$ ]]
	then
		echo [RELEASE] Release abortado
		echo
	    exit 1
	fi	
fi

echo "[RELEASE] Alterando a versao da master para a versao do release $NEW_VERSION"

git checkout master -q
git pull origin master -q
mvn -q versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false
mvn -q -f pom.xml versions:set -DnewVersion=$NEW_VERSION -DgenerateBackupPoms=false
git add .
result=`git status -s`
if [ ! -z "$result" -a "$result" != " " ]; then
	git commit -m "Release $NEW_VERSION" -q
	git push origin master -q
fi

echo [RELEASE] Gerando a TAG

PROJECT_NAME=${PWD##*/}

git tag -a $PROJECT_NAME-$NEW_VERSION -m "Release $NEW_VERSION"
git push origin $PROJECT_NAME-$NEW_VERSION -q

echo "[RELEASE] Alterando a versao da master para a versao de manutencao $NEW_MANUT_VERSION"

mvn -q versions:set -DnewVersion=$NEW_MANUT_VERSION -DgenerateBackupPoms=false
mvn -q -f pom.xml versions:set -DnewVersion=$NEW_MANUT_VERSION -DgenerateBackupPoms=false
git add .
git commit -m "Release $NEW_VERSION" -q
git push origin master -q

echo "[RELEASE] Fazendo merge da develop na master"

git checkout develop -q
git pull origin develop -q
git merge -X ours master

echo "[RELEASE] Merge feito!"

echo "[RELEASE] Release gerado com sucesso :D"