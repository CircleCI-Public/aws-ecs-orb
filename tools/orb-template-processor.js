const Handlebars = require('handlebars'),
fs = require('fs');
const templateContents = fs.readFileSync(process.argv[2]).toString();
const containerDefsScript = fs.readFileSync("src/python/update_container_definitions.py").toString();
const getTaskDefScript = fs.readFileSync("src/python/get_task_definition_value.py").toString();

// Use partials to preserve indentation
Handlebars.registerPartial('UPDATE_CONTAINER_DEFS_SCRIPT_SRC', '{{{updateContainers}}}');
Handlebars.registerPartial('GET_TASK_DFN_VAL_SCRIPT_SRC', '{{{getTaskDfnVal}}}');
const config = {
    updateContainers: containerDefsScript,
    getTaskDfnVal: getTaskDefScript
};
const template = Handlebars.compile(templateContents);
const result = template(config);
console.log(result);
