'use strict'

module.exports = {
    up: async(queryInterface, Sequelize) => {
        await queryInterface.addColumn('Articles', 'visibility', {
            type: Sequelize.ENUM('public', 'private'),
            allowNull: false,
            defaultValue: 'public'
        })

        await queryInterface.addColumn('Articles', 'userId', {
            type: Sequelize.INTEGER,
            allowNull: true,
            references: {
                model: 'Users',
                key: 'id'
            },
            onUpdate: 'CASCADE',
            onDelete: 'SET NULL'
        })

        await queryInterface.addIndex('Articles', ['visibility'])
        await queryInterface.addIndex('Articles', ['userId'])
    },

    down: async(queryInterface, Sequelize) => {
        await queryInterface.removeIndex('Articles', ['userId'])
        await queryInterface.removeIndex('Articles', ['visibility'])
        await queryInterface.removeColumn('Articles', 'userId')
        await queryInterface.removeColumn('Articles', 'visibility')
        await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_Articles_visibility";')
    }
}
