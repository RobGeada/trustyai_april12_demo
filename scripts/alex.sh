sed "s&resources/odh-minimal.yaml&${1}&g" scripts/install.sh > scripts/alex_install.sh

scripts/alex_install.sh
scripts/deploy_models.sh
scripts/send_data_batch.sh batch_01
scripts/send_data_batch.sh batch_02
scripts/register_metric_monitoring.sh

rm scripts/alex_install.sh