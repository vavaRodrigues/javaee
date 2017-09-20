#!/bin/bash
set -e	

# CALCULA AS VERSOES BASEADA NA DEVELOP
git checkout develop
git pull origin develop -q
CURRENT_DEVELOP_VERSION=`mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`
NEW_VERSION=${CURRENT_DEVELOP_VERSION%-*}
NEW_MAINTAINENCE_VERSION=${NEW_VERSION%.*}.1-SNAPSHOT
NEW_DEVELOP_VERSION=${NEW_VERSION%.*}
NEW_DEVELOP_VERSION=1.`expr ${NEW_DEVELOP_VERSION#*.} + 1`.0-SNAPSHOT

# PEDE CONFIRMACAO DAS VERSOES
echo "[RELEASE] --------------------------------------------------"
echo "[RELEASE] Versao atual de desenvolvimento..$CURRENT_DEVELOP_VERSION"
echo "[RELEASE] Release a ser gerado.............$NEW_VERSION"
echo "[RELEASE] Nova versao de manutencao........$NEW_MAINTAINENCE_VERSION"
echo "[RELEASE] Nova versao de desenvolvimento...$NEW_DEVELOP_VERSION"
echo "[RELEASE] --------------------------------------------------"

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

echo "[RELEASE] Fazendo o merge da develop na master"
git fetch -p -q
git checkout master -q
git pull origin master -q
git merge develop -X theirs -q -m "Merge do release $NEW_VERSION"

echo "[RELEASE] Alterando a versao da master para a versao do release $NEW_VERSION"

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

echo "[RELEASE] Alterando a versao da master para a versao de manutencao $NEW_MAINTAINENCE_VERSION"

mvn -q versions:set -DnewVersion=$NEW_MAINTAINENCE_VERSION -DgenerateBackupPoms=false
mvn -q -f pom.xml versions:set -DnewVersion=$NEW_MAINTAINENCE_VERSION -DgenerateBackupPoms=false
git add .
git commit -m "Release $NEW_VERSION" -q
git push origin master -q

echo "[RELEASE] Alterando a versao da develop para a versao de desenvolvimento $NEW_DEVELOP_VERSION"

git checkout develop -q
git pull origin develop -q
mvn -q versions:set -DnewVersion=$NEW_DEVELOP_VERSION -DgenerateBackupPoms=false
mvn -q -f pom.xml versions:set -DnewVersion=$NEW_DEVELOP_VERSION -DgenerateBackupPoms=false
git add .
git commit -m "Release $NEW_VERSION" -q
git push origin develop -q

echo "[RELEASE] Release gerado com sucesso :D"